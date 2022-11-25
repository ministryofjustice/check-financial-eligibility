require "swagger_helper"

RSpec.describe "partner_financials", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/assessments/{assessment_id}/partner_financials" do
    post("create ") do
      tags "Assessment components"
      consumes "application/json"
      produces "application/json"

      description <<~DESCRIPTION.chomp
        Adds details of an applicant's partner.
      DESCRIPTION

      assessment_id_parameter

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[partner],
                  description: "Full information about an applicant's partner",
                  example: JSON.parse(File.read(Rails.root.join("spec/fixtures/partner_financials.json"))),
                  properties: {
                    partner: {
                      type: :object,
                      description: "The partner of the applicant",
                      required: %i[date_of_birth employed],
                      properties: {
                        date_of_birth: {
                          type: :string,
                          format: :date,
                          example: "1992-07-22",
                          description: "Applicant's partner's date of birth",
                        },
                        employed: {
                          type: :boolean,
                          example: true,
                          description: "Whether the applicant's partner is employed",
                        },
                      },
                    },
                    irregular_incomes: {
                      type: :array,
                      required: %i[income_type frequency amount],
                      description: "One or more irregular payment details",
                      items: {
                        type: :object,
                        description: "Irregular payment detail",
                        properties: {
                          income_type: {
                            type: :string,
                            enum: CFEConstants::VALID_IRREGULAR_INCOME_TYPES,
                            description: "Identifying name for this irregular income payment",
                            example: CFEConstants::VALID_IRREGULAR_INCOME_TYPES.first,
                          },
                          frequency: {
                            type: :string,
                            enum: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES,
                            description: "Frequency of the payment received",
                            example: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES.first,
                          },
                          amount: {
                            type: :number,
                            format: :decimal,
                            example: 101.01,
                          },
                        },
                      },
                    },
                    employments: {
                      type: :array,
                      required: %i[name client_id payments],
                      description: "One or more employment income details",
                      items: {
                        type: :object,
                        description: "Employment income detail",
                        properties: {
                          name: {
                            type: :string,
                            description: "Identifying name for this employment - e.g. employer's name",
                          },
                          client_id: {
                            type: :string,
                            description: "Client supplied id to identify the employment",
                          },
                          payments: {
                            type: :array,
                            required: %i[client_id date gross benefits_in_kind tax national_insurance net_employment_income],
                            description: "One or more employment payment details",
                            items: {
                              type: :object,
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
                                  description: "Amount of tax paid",
                                },
                                national_insurance: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Amount of national insurance paid",
                                },
                                net_employment_income: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Net payment income received",
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    regular_transactions: {
                      type: :array,
                      required: %i[category operation frequency amount],
                      description: "Zero or more regular transactions",
                      items: {
                        type: :object,
                        description: "regular transaction detail",
                        properties: {
                          category: {
                            type: :string,
                            enum: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES + CFEConstants::VALID_OUTGOING_CATEGORIES,
                            description: "Identifying category for this regular transaction",
                            example: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES.first,
                          },
                          operation: {
                            type: :string,
                            enum: %w[credit debit],
                            description: "Identifying operation for this regular transaction",
                            example: "credit",
                          },
                          frequency: {
                            type: :string,
                            enum: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES,
                            description: "Frequency with which regular transaction is made or received",
                            example: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES.first,
                          },
                          amount: {
                            type: :number,
                            format: :decimal,
                            example: 101.01,
                          },
                        },
                      },
                    },
                    state_benefits: {
                      type: :array,
                      description: "One or more state benefits receved by the applicant's partner and categorized by name",
                      items: {
                        type: :object,
                        required: %i[name payments],
                        description: "State benefit payment detail",
                        properties: {
                          name: {
                            type: :string,
                            description: "Name of the state benefit",
                            example: "my_state_bnefit",
                          },
                          payments: {
                            type: :array,
                            required: %i[client_id date amount],
                            description: "One or more state benefit payments details",
                            items: {
                              type: :object,
                              description: "Payment detail",
                              properties: {
                                client_id: {
                                  type: :string,
                                  format: :uuid,
                                  description: "Client identifier for payment received",
                                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                },
                                date: {
                                  type: :string,
                                  format: :date,
                                  description: "Date payment received",
                                  example: "1992-07-22",
                                },
                                amount: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Amount of payment received",
                                  example: 101.01,
                                },
                                flags: {
                                  type: :object,
                                  description: "Line items that should be flagged to caseworkers for review",
                                  example: { multi_benefit: true },
                                  properties: {
                                    multi_benefit: {
                                      type: :boolean,
                                    },
                                  },
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    additional_properties: {
                      type: :array,
                      required: %i[value outstanding_mortgage percentage_owned shared_with_housing_assoc],
                      description: "One or more additional properties owned by the applicant's partner",
                      items: {
                        type: :object,
                        description: "Additional property details",
                        properties: {
                          value: {
                            type: :number,
                            format: :decimal,
                            description: "Financial value of the property",
                            example: 500_000.01,
                          },
                          outstanding_mortgage: {
                            type: :number,
                            format: :decimal,
                            description: "Amount outstanding on all mortgages against this property",
                            example: 999.99,
                          },
                          percentage_owned: {
                            type: :number,
                            format: :decimal,
                            description: "Percentage share of the property which is owned by the applicant's partner",
                            example: 99.99,
                          },
                          shared_with_housing_assoc: {
                            type: :boolean,
                            description: "Property is shared with a housing association",
                          },
                          subject_matter_of_dispute: {
                            type: :boolean,
                            description: "Property is the subject of a dispute",
                          },
                        },
                      },
                    },
                    capital_items: {
                      type: :object,
                      required: %i[bank_accounts non_liquid_capital],
                      description: "Element's of the applicant's partners capital",
                      properties: {
                        bank_accounts: {
                          type: :array,
                          description: "One or more account details",
                          example: [{ value: 1.01, description: "test name 1", subject_matter_of_dispute: false },
                                    { value: 100.01, description: "test name 2", subject_matter_of_dispute: true }],
                          items: {
                            type: :object,
                            description: "Account detail",
                            properties: {
                              value: {
                                type: :number,
                                format: :decimal,
                              },
                              description: {
                                type: :string,
                              },
                              subject_matter_of_dispute: {
                                type: :boolean,
                              },
                            },
                          },
                        },
                        non_liquid_capital: {
                          type: :array,
                          description: "One or more non liquid assets owned by the client's partner",
                          example: [{ value: 1.01, description: "test name 1", subject_matter_of_dispute: false },
                                    { value: 100.01, description: "test name 2", subject_matter_of_dispute: true }],
                          items: {
                            type: :object,
                            description: "Asset detail",
                            properties: {
                              value: {
                                type: :number,
                                format: :decimal,
                              },
                              description: {
                                type: :string,
                              },
                              subject_matter_of_dispute: {
                                type: :boolean,
                              },
                            },
                          },
                        },
                      },
                    },
                    vehicles: {
                      type: :array,
                      description: "One or more vehicles' details",
                      items: {
                        type: :object,
                        required: %i[value date_of_purchase],
                        properties: {
                          value: {
                            type: :number,
                            format: :decimal,
                            description: "Financial value of the vehicle",
                          },
                          loan_amount_outstanding: {
                            type: :number,
                            format: :decimal,
                            description: "Amount remaining, if any, of a loan used to purchase the vehicle",
                          },
                          date_of_purchase: {
                            type: :string,
                            format: :dates,
                            description: "Date vehicle purchased by the applicant's partner",
                          },
                          in_regular_use: {
                            type: :boolean,
                            description: "Vehicle in regular use or not",
                          },
                          subject_matter_of_dispute: {
                            type: :boolean,
                            description: "Whether this vehicle is the subject of a dispute",
                          },
                        },
                      },
                    },
                    dependants: {
                      type: :array,
                      description: "One or more dependants details",
                      items: {
                        type: :object,
                        required: %i[date_of_birth in_full_time_education relationship],
                        properties: {
                          date_of_birth: {
                            type: :string,
                            format: :date,
                            example: "1992-07-22",
                          },
                          in_full_time_education: {
                            type: :boolean,
                            example: false,
                            description: "Dependant is in full time education or not",
                          },
                          relationship: {
                            type: :string,
                            enum: Dependant.relationships.values,
                            example: Dependant.relationships.values.first,
                            description: "Dependant's relationship to the applicant's partner",
                          },
                          monthly_income: {
                            type: :number,
                            format: :decimal,
                            description: "Dependant's monthly income",
                            example: 101.01,
                          },
                          assets_value: {
                            type: :number,
                            format: :decimal,
                            description: "Dependant's total assets value",
                            example: 0.0,
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        let(:assessment_id) { create(:assessment).id }
        before do
          create(:state_benefit_type, label: "other")
        end

        let(:params) do
          {
            partner: {
              date_of_birth: "1992-07-22",
              employed: true,
            },
            irregular_incomes: [
              {
                income_type: CFEConstants::VALID_IRREGULAR_INCOME_TYPES.first,
                frequency: CFEConstants::VALID_IRREGULAR_INCOME_FREQUENCIES.first,
                amount: 101.01,
              },
            ],
            employments: [
              {
                name: "A",
                client_id: "B",
                payments: [
                  {
                    client_id: "C",
                    date: "1992-07-22",
                    gross: 101.01,
                    benefits_in_kind: 0.0,
                    tax: 11,
                    national_insurance: 3.0,
                    net_employment_income: 87.01,
                  },
                ],
              },
            ],
            regular_transactions: [
              {
                category: CFEConstants::VALID_REGULAR_INCOME_CATEGORIES.first,
                operation: "credit",
                frequency: CFEConstants::VALID_REGULAR_TRANSACTION_FREQUENCIES.first,
                amount: 101.01,
              },
            ],
            state_benefits: [
              {
                name: "D",
                payments: [
                  {
                    client_id: "E",
                    date: "1992-07-22",
                    amount: 101.01,
                    flags: {
                      multi_benefit: false,
                    },
                  },
                ],
              },
            ],
            additional_properties: [
              {
                value: 500_000.01,
                outstanding_mortgage: 999.99,
                percentage_owned: 100,
                shared_with_housing_assoc: false,
                subject_matter_of_dispute: false,
              },
            ],
            capital_items: {
              bank_accounts: [
                {
                  value: 1.01,
                  description: "F",
                  subject_matter_of_dispute: false,
                },
              ],
              non_liquid_capital: [
                {
                  value: 1.01,
                  description: "G",
                  subject_matter_of_dispute: false,
                },
              ],
            },
            vehicles: [
              {
                value: 5_000,
                loan_amount_outstanding: 1_000,
                date_of_purchase: "2017-01-23",
                in_regular_use: true,
                subject_matter_of_dispute: false,
              },
            ],
            dependants: [
              {
                date_of_birth: "1983-08-08",
                in_full_time_education: false,
                relationship: "adult_relative",
                monthly_income: 4448.63,
                assets_value: 0.0,
              },
            ],
          }
        end

        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => {
              example: JSON.parse(response.body, symbolize_names: true),
            },
          }
        end

        run_test!
      end

      response(422, "Unprocessable Entity") do\
        let(:assessment_id) { create(:assessment).id }

        let(:params) { { partner: {} } }

        run_test! do |response|
          body = JSON.parse(response.body, symbolize_names: true)
          expect(body[:errors]).to include(/The property '#\/' did not contain a required property of 'date_of_birth' in schema file:\/\/#/)
        end
      end
    end
  end
end
