# frozen_string_literal: true

require "rails_helper"
require "swagger_parameter_helpers"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger")

  api_description = <<~DESCRIPTION.chomp
    # Check financial eligibility for legal aid.

    ## Usage:
      - Create an assessment by POSTing a payload to `/assessments`
        and store the `assessment_id` returned.
      - Add assessment components, such as applicant, capitals and properties using the
        `assessment_id` from the first call
      - Retrieve the result using the GET `/assessments/{assessment_id}`
  DESCRIPTION

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "v5/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "API V5",
        description: api_description,
        contact: {
          name: "Github repository",
          url: "https://github.com/ministryofjustice/check-financial-eligibility",
        },
        version: "v5",
      },
      components: {
        schemas: {
          currency: {
            description: "A negative or positive number (including zero) with two decimal places",
            type: :number,
            format: :decimal,
            multipleOf: 0.01,
          },
          positive_currency: {
            "description": "Non-negative number (including zero) with two decimal places",
            type: :number,
            format: :decimal,
            minimum: 0.0,
            multipleOf: 0.01,
          },
          ProceedingTypeResult: {
            type: :object,
            required: %i[ccms_code client_involvement_type upper_threshold lower_threshold result],
            properties: {
              ccms_code: {
                type: :string,
                enum: CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES,
                description: "The code expected by CCMS",
              },
              client_involvement_type: {
                type: :string,
                enum: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES,
                example: "A",
                description: "The client_involvement_type expected by CCMS",
              },
              upper_threshold: { type: :number },
              lower_threshold: { type: :number },
              result: {
                type: :string,
                enum: %w[eligible ineligible contribution_required],
              },
            },
          },
          Property: {
            type: :object,
            additionalProperties: false,
            properties: {
              value: {
                type: :number,
                minimum: 0.0,
              },
              outstanding_mortgage: {
                type: :number,
                minimum: 0.0,
              },
              # The minimum has to be zero because we have to have a 'dummy' main home sometimes
              percentage_owned: {
                type: :integer,
                minimum: 0,
                maximum: 100,
              },
              main_home: {
                type: :boolean,
              },
              shared_with_housing_assoc: {
                type: :boolean,
              },
              transaction_allowance: {
                type: :number,
                minimum: 0.0,
              },
              allowable_outstanding_mortgage: {
                type: :number,
                minimum: 0.0,
              },
              net_value: {
                type: :number,
              },
              net_equity: {
                type: :number,
              },
              smod_allowance: {
                type: :number,
                description: "Amount of subject matter of dispute disregard applied to this property",
                minimum: 0.0,
                maximum: 100_000.0,
              },
              main_home_equity_disregard: {
                type: :number,
                description: "Amount of main home equity disregard applied to this property",
              },
              assessed_equity: {
                type: :number,
                minimum: 0.0,
              },
            },
          },
          BankAccounts: {
            type: :array,
            description: "Describes the name of the bank account and the lowest balance during the computation period",
            example: [{ value: 1.01, description: "test name 1", subject_matter_of_dispute: false },
                      { value: 100.01, description: "test name 2", subject_matter_of_dispute: true }],
            items: {
              type: :object,
              description: "Account detail",
              additionalProperties: false,
              required: %i[value description],
              properties: {
                value: { "$ref" => "#/components/schemas/currency" },
                description: {
                  type: :string,
                },
                subject_matter_of_dispute: {
                  description: "Whether the contents of this bank account are the subject of a dispute",
                  type: :boolean,
                },
              },
            },
          },
          Capitals: {
            type: :object,
            additionalProperties: false,
            properties: {
              bank_accounts: { "$ref" => "#/components/schemas/BankAccounts" },
              non_liquid_capital: {
                type: :array,
                description: "An array of objects describing applicant's non-liquid capital items (excluding property), e.g. valuable items, jewellery, trusts, other investments",
                example: [{ value: 1.01, description: "asset name 1", subject_matter_of_dispute: false },
                          { value: 100.01, description: "asset name 2", subject_matter_of_dispute: true }],
                items: {
                  type: :object,
                  description: "Asset detail",
                  required: %i[value description],
                  additionalProperties: false,
                  properties: {
                    value: { "$ref" => "#/components/schemas/positive_currency" },
                    description: {
                      description: "Definition of a non-liquid capital item",
                      type: :string,
                    },
                    subject_matter_of_dispute: {
                      description: "Whether the item is the subject of a dispute",
                      type: :boolean,
                    },
                  },
                },
              },
            },
          },
          EmploymentPaymentList: {
            type: :array,
            description: "One or more employment payment details",
            minItems: 1,
            items: {
              type: :object,
              # allow for legacy redundant net_employment_income field
              additionalProperties: true,
              description: "Employment payment detail",
              properties: {
                client_id: {
                  type: :string,
                  description: "Client supplied id to identify the payment",
                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                },
                date: {
                  type: :string,
                  format: :date,
                  description: "Date payment received",
                  example: "1992-07-22",
                },
                gross: {
                  type: :number,
                  format: :decimal,
                  description: "Gross payment income received",
                  example: "101.01",
                },
                benefits_in_kind: {
                  type: :number,
                  format: :decimal,
                  description: "Benefit in kind amount received",
                },
                tax: {
                  type: :number,
                  format: :decimal,
                  description: "Amount of tax paid - normally negative, but can be positive for a tax refund",
                  example: "-10.01",
                },
                national_insurance: {
                  type: :number,
                  format: :decimal,
                  description: "Amount of national insurance paid - normally negative, but can be positive for a tax refund",
                  example: "-5.24",
                },
              },
            },
          },
          Asset: {
            type: :object,
            additionalProperties: false,
            required: %i[value description],
            value: {
              type: :number,
              format: :decimal,
              description: "Value of asset",
            },
            description: {
              type: :number,
              format: :decimal,
              description: "Description of asset",
            },
          },
        },
      },
      paths: {},
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml

  # mixin custom application specific swagger helpers
  config.extend SwaggerParameterHelpers, type: :request
end
