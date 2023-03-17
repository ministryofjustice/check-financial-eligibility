require "swagger_helper"

RSpec.describe "full_assessment", type: :request, swagger_doc: "v5/swagger.yaml" do
  path "/v2/assessments" do
    post("create") do
      tags "Perform assessment with single call"
      consumes "application/json"
      produces "application/json"

      description << "Performs a complete assessment"

      parameter name: :params,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %i[assessment applicant proceeding_types],
                  properties: {
                    assessment: {
                      type: :object,
                      additionalProperties: false,
                      required: %i[submission_date level_of_help],
                      properties: {
                        submission_date: {
                          type: :string,
                          format: :date,
                          example: "2023-02-05",
                          description: "Date of the original submission (iso8601 format)",
                        },
                        client_reference_id: {
                          type: :string,
                          example: "LA-FOO-BAR",
                          description: "Client's reference number for this application (free text)",
                        },
                        level_of_help: {
                          type: :string,
                          enum: Assessment.levels_of_help.keys,
                          example: Assessment.levels_of_help.keys.first,
                          description: "The level of representation required by the client",
                        },
                      },
                    },
                    applicant: {
                      type: :object,
                      required: %i[date_of_birth has_partner_opponent receives_qualifying_benefit],
                      description: "Object describing pertinent applicant details",
                      properties: {
                        date_of_birth: { type: :string,
                                         format: :date,
                                         example: "1992-07-22",
                                         description: "Applicant date of birth" },
                        has_partner_opponent: { type: :boolean,
                                                example: false,
                                                description: "Applicant has partner opponent" },
                        receives_qualifying_benefit: { type: :boolean,
                                                       example: false,
                                                       description: "Applicant receives qualifying benefit" },
                      },
                    },
                    proceeding_types: {
                      type: :array,
                      description: "One or more proceeding_type details",
                      minItems: 1,
                      items: {
                        type: :object,
                        required: %i[ccms_code client_involvement_type],
                        properties: {
                          ccms_code: {
                            type: :string,
                            example: "DA001",
                            description: "The code expected by CCMS",
                          },
                          client_involvement_type: {
                            type: :string,
                            enum: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES,
                            example: "A",
                            description: "The client_involvement_type expected by CCMS",
                          },
                        },
                      },
                    },
                    capitals: { "$ref" => "#/components/schemas/Capitals" },
                    cash_transactions: {
                      type: :object,
                      description: "A set of cash income[ings] and outgoings payments by category",
                      example: JSON.parse(File.read(Rails.root.join("spec/fixtures/cash_transactions.json"))
                                              .gsub("3.months.ago", "2022-01-01")
                                              .gsub("2.months.ago", "2022-02-01")
                                              .gsub("1.month.ago", "2022-03-01")),
                      properties: {
                        income: {
                          type: :array,
                          description: "One or more income details",
                          items: {
                            type: :object,
                            description: "Income detail",
                            additionalProperties: false,
                            required: %i[category payments],
                            properties: {
                              category: {
                                type: :string,
                                enum: CFEConstants::VALID_INCOME_CATEGORIES,
                                example: CFEConstants::VALID_INCOME_CATEGORIES.first,
                              },
                              payments: {
                                type: :array,
                                description: "One or more payment details",
                                items: {
                                  type: :object,
                                  description: "Payment detail",
                                  required: %i[amount client_id date],
                                  properties: {
                                    date: {
                                      type: :string,
                                      format: :date,
                                      example: "1992-07-22",
                                    },
                                    amount: {
                                      type: :number,
                                      format: :decimal,
                                      example: "101.01",
                                    },
                                    client_id: {
                                      type: :string,
                                      format: :uuid,
                                      example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                    },
                                  },
                                },
                              },
                            },
                          },
                        },
                        outgoings: {
                          type: :array,
                          description: "One or more outgoing details",
                          items: {
                            type: :object,
                            description: "Outgoing detail",
                            additionalProperties: false,
                            required: %i[category payments],
                            properties: {
                              category: {
                                type: :string,
                                enum: CFEConstants::VALID_OUTGOING_CATEGORIES,
                                example: CFEConstants::VALID_OUTGOING_CATEGORIES.first,
                              },
                              payments: {
                                type: :array,
                                description: "One or more payment details",
                                items: {
                                  type: :object,
                                  description: "Payment detail",
                                  required: %i[amount client_id date],
                                  properties: {
                                    date: {
                                      type: :string,
                                      format: :date,
                                      example: "1992-07-22",
                                    },
                                    amount: {
                                      type: :number,
                                      format: :decimal,
                                      example: "101.02",
                                    },
                                    client_id: {
                                      type: :string,
                                      format: :uuid,
                                      example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                    },
                                  },
                                },
                              },
                            },
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
                            description: "Dependant's relationship to the applicant",
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
                    employment_income: {
                      type: :array,
                      description: "One or more employment income details",
                      items: {
                        type: :object,
                        description: "Employment income detail",
                        required: %i[name client_id payments],
                        properties: {
                          name: {
                            type: :string,
                            description: "Identifying name for this employment - e.g. employer's name",
                          },
                          client_id: {
                            type: :string,
                            description: "Client supplied id to identify the employment",
                          },
                          receiving_only_statutory_sick_or_maternity_pay: {
                            type: :boolean,
                            description: "Client is in receipt only of Statutory Sick Pay (SSP) or Statutory Maternity Pay (SMP)",
                          },
                          payments: { "$ref" => "#/components/schemas/EmploymentPaymentList" },
                        },
                      },
                    },
                    irregular_incomes: {
                      type: :object,
                      description: "A set of irregular income payments",
                      example: { payments: [{ income_type: "student_loan", frequency: "annual", amount: 123_456.78 }] },
                      properties: {
                        payments: {
                          type: :array,
                          required: %i[income_type frequency amount],
                          description: "One or more irregular payment details",
                          minItems: 0,
                          maxItems: 2,
                          items: {
                            type: :object,
                            description: "Irregular payment detail",
                            required: %i[income_type frequency amount],
                            additionalProperties: false,
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
                      },
                    },
                    other_incomes: {
                      type: :array,
                      description: "One or more other regular income payments categorized by source",
                      items: {
                        type: :object,
                        description: "Other regular income detail",
                        required: %i[source],
                        properties: {
                          source: {
                            type: :string,
                            enum: CFEConstants::HUMANIZED_INCOME_CATEGORIES,
                            description: "Source of other regular income",
                            example: CFEConstants::HUMANIZED_INCOME_CATEGORIES.first,
                          },
                          payments: {
                            type: :array,
                            description: "One or more other regular payment details",
                            items: {
                              type: :object,
                              description: "Payment detail",
                              required: %i[date amount client_id],
                              properties: {
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
                                client_id: {
                                  type: :string,
                                  format: :uuid,
                                  description: "Client identifier for payment received",
                                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    outgoings: {
                      type: :array,
                      required: %i[name payments],
                      description: "One or more outgoings categorized by name",
                      items: {
                        type: :object,
                        description: "Outgoing payments detail",
                        properties: {
                          name: {
                            type: :string,
                            enum: CFEConstants::VALID_OUTGOING_CATEGORIES,
                            description: "Type of outgoing",
                            example: CFEConstants::VALID_OUTGOING_CATEGORIES.first,
                          },
                          payments: {
                            type: :array,
                            required: %i[client_id payment_date amount],
                            description: "One or more outgoing payments detail",
                            items: {
                              type: :object,
                              description: "Payment detail",
                              properties: {
                                client_id: {
                                  type: :string,
                                  description: "Client identifier for outgoing payment",
                                  example: "05459c0f-a620-4743-9f0c-b3daa93e5711",
                                },
                                payment_date: {
                                  type: :string,
                                  format: :date,
                                  description: "Date payment made",
                                  example: "1992-07-22",
                                },
                                housing_costs_type: {
                                  type: :string,
                                  enum: CFEConstants::VALID_OUTGOING_HOUSING_COST_TYPES,
                                  description: "Housing cost type (omit for non-housing cost outgoings)",
                                  example: CFEConstants::VALID_OUTGOING_HOUSING_COST_TYPES.first,
                                },
                                amount: {
                                  type: :number,
                                  format: :decimal,
                                  description: "Amount of payment made",
                                  example: 101.01,
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                    properties: {
                      type: :object,
                      required: %i[main_home],
                      description: "A main home and additional properties",
                      properties: {
                        main_home: {
                          type: :object,
                          required: %i[value outstanding_mortgage percentage_owned shared_with_housing_assoc],
                          description: "Applicant's main home details",
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
                              description: "Percentage share of the property which is owned by the applicant",
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
                        additional_properties: {
                          type: :array,
                          description: "One or more additional properties owned by the applicant",
                          items: {
                            type: :object,
                            description: "Additional property details",
                            required: %i[value outstanding_mortgage percentage_owned shared_with_housing_assoc],
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
                                description: "Percentage share of the property which is owned by the applicant",
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
                      },
                    },
                    regular_transactions: {
                      type: :array,
                      required: %i[category operation frequency amount],
                      description: "Zero or more regular transactions",
                      items: {
                        type: :object,
                        description: "regular transaction detail",
                        required: %i[category operation frequency amount],
                        additionalProperties: false,
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
                      description: "One or more state benefits receved by the applicant and categorized by name",
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
                            format: :date,
                            description: "Date vehicle purchased by the applicant",
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
                    partner: {
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
                              payments: { "$ref" => "#/components/schemas/EmploymentPaymentList" },
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
                        capital_items: { "$ref" => "#/components/schemas/Capitals" },
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
                    },
                    explicit_remarks: {
                      type: :array,
                      required: %i[category details],
                      description: "One or more remarks by category",
                      items: {
                        type: :object,
                        description: "Explicit remark",
                        properties: {
                          category: {
                            type: :string,
                            enum: CFEConstants::VALID_REMARK_CATEGORIES,
                            description: "Category of remark. Currently, only 'policy_disregard' is supported",
                            example: CFEConstants::VALID_REMARK_CATEGORIES.first,
                          },
                          details: {
                            type: :array,
                            description: "One or more remarks for that category",
                            items: {
                              type: :string,
                            },
                          },
                        },
                      },
                    },
                  },
                }

      response(200, "successful") do
        schema type: :object,
               required: %i[timestamp result_summary assessment version success],
               properties: {
                 timestamp: {
                   type: :string,
                 },
                 result_summary: {
                   type: :object,
                   required: %i[overall_result gross_income disposable_income capital],
                   properties: {
                     overall_result: {
                       type: :object,
                       required: %i[result capital_contribution income_contribution proceeding_types],
                       properties: {
                         result: {
                           type: :string,
                           enum: %w[eligible ineligible contribution_required],
                         },
                         capital_contribution: { type: :number },
                         income_contribution: { type: :number },
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                       },
                     },
                     gross_income: {
                       type: :object,
                       required: %i[total_gross_income combined_total_gross_income proceeding_types],
                       properties: {
                         total_gross_income: { type: :number },
                         combined_total_gross_income: { type: :number },
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                       },
                     },
                     partner_gross_income: {
                       type: :object,
                       required: %i[total_gross_income],
                       properties: {
                         total_gross_income: { type: :number },
                       },
                     },
                     disposable_income: {
                       type: :object,
                       properties: {
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                         income_contribution: { type: :number },
                         combined_total_outgoings_and_allowances: { type: :number },
                         total_disposable_income: { type: :number },
                         combined_total_disposable_income: { type: :number },
                         total_outgoings_and_allowances: { type: :number },
                         dependant_allowance: { type: :number },
                         gross_housing_costs: { type: :number },
                         housing_benefit: { type: :number },
                         net_housing_costs: { type: :number },
                         maintenance_allowance: { type: :number },
                         employment_income: { type: :object },
                         partner_allowance: { type: :number },
                       },
                     },
                     partner_disposable_income: {
                       type: :object,
                       properties: {
                         income_contribution: { type: :number },
                         total_disposable_income: { type: :number },
                         total_outgoings_and_allowances: { type: :number },
                         dependant_allowance: { type: :number },
                         gross_housing_costs: { type: :number },
                         housing_benefit: { type: :number },
                         net_housing_costs: { type: :number },
                         maintenance_allowance: { type: :number },
                         employment_income: { type: :object },
                       },
                     },
                     capital: {
                       type: :object,
                       additionalProperties: false,
                       properties: {
                         proceeding_types: {
                           type: :array,
                           items: { "$ref" => "#/components/schemas/ProceedingTypeResult" },
                         },
                         total_liquid: {
                           type: :number,
                           description: "Total value of all client liquid assets in submission",
                           format: :decimal,
                         },
                         total_non_liquid: {
                           description: "Total value of all client non-liquid assets in submission",
                           type: :number,
                           format: :decimal,
                           minimum: 0.0,
                         },
                         total_vehicle: {
                           description: "Total value of all client vehicle assets in submission",
                           type: :number,
                           format: :decimal,
                         },
                         total_property: {
                           description: "Total value of all client property assets in submission",
                           type: :number,
                           format: :decimal,
                         },
                         total_mortgage_allowance: {
                           description: "Maxiumum mortgage allowance used in submission. Cases April 2020 will all be set to 999_999_999",
                           type: :number,
                           format: :decimal,
                         },
                         total_capital: {
                           description: "Total value of all capital assets in submission",
                           type: :number,
                           format: :decimal,
                         },
                         pensioner_capital_disregard: {
                           type: :number,
                           format: :decimal,
                           description: "Cap on pensioner capital disregard for this assessment (based on disposable_income)",
                           minimum: 0.0,
                         },
                         total_capital_with_smod: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of capital with subject matter of dispute deduction applied",
                         },
                         disputed_non_property_disregard: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of subject matter of dispute deduction applied for assets other than property",
                         },
                         pensioner_disregard_applied: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of pensioner capital disregard applied to this assessment",
                         },
                         subject_matter_of_dispute_disregard: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Total amount of subject matter of dispute disregard applied on this submission",
                         },
                         capital_contribution: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Assessed capital contribution. Will only be non-zero for 'contribution_required' cases",
                         },
                         assessed_capital: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of assessed client capital. Zero if deductions exceed total capital.",
                         },
                         combined_assessed_capital: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Amount of assessed capital for both client and partner",
                         },
                         combined_capital_contribution: {
                           type: :number,
                           format: :decimal,
                           minimum: 0,
                           description: "Synonym for capital_contribution",
                         },
                       },
                     },
                     partner_capital: {
                       type: :object,
                       properties: {
                         total_liquid: { type: :number },
                         total_non_liquid: { type: :number },
                         total_vehicle: { type: :number },
                         total_property: { type: :number },
                         total_mortgage_allowance: { type: :number },
                         total_capital: { type: :number },
                         pensioner_capital_disregard: { type: :number },
                         subject_matter_of_dispute_disregard: { type: :number },
                         capital_contribution: { type: :number },
                         assessed_capital: { type: :number },
                       },
                     },
                   },
                 },
                 assessment: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     client_reference_id: { type: :string, nullable: true, example: "ref-11-22" },
                     submission_date: { type: :string, format: :date, example: "2022-07-22" },
                     applicant: { type: :object },
                     gross_income: { type: :object },
                     disposable_income: { type: :object },
                     capital: {
                       type: :object,
                       additionalProperties: false,
                       properties: {
                         capital_items: {
                           type: :object,
                           additionalProperties: false,
                           required: %i[liquid non_liquid vehicles properties],
                           properties: {
                             liquid: {
                               type: :array,
                               items: { "$ref" => "#/components/schemas/Asset" },
                             },
                             non_liquid: {
                               type: :array,
                               items: { "$ref" => "#/components/schemas/Asset" },
                             },
                             vehicles: {
                               type: :array,
                               items: { "$ref" => "#/components/schemas/Asset" },
                             },
                             properties: {
                               type: :object,
                               additionalProperties: false,
                               properties: {
                                 main_home: {
                                   "$ref" => "#/components/schemas/Property",
                                 },
                                 additional_properties: {
                                   type: :array,
                                   items: {
                                     "$ref" => "#/components/schemas/Property",
                                   },
                                 },
                               },
                             },
                           },
                         },
                       },
                     },
                   },
                 },
                 version: {
                   type: :string,
                   enum: %w[5],
                 },
                 success: {
                   type: :boolean,
                 },
               }

        let(:params) do
          {
            assessment: { submission_date: "2022-06-06" },
            applicant: { date_of_birth: "2001-02-02", has_partner_opponent: false, receives_qualifying_benefit: false, employed: false },
            proceeding_types: [{ ccms_code: "DA001", client_involvement_type: "A" }],
          }
        end

        run_test!
      end
    end
  end
end
