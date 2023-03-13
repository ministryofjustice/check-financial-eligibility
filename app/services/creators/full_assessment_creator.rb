module Creators
  class FullAssessmentCreator
    class << self
      CreationResult = Struct.new :errors, :assessment, keyword_init: true do
        def success?
          errors.empty?
        end
      end

      def call(remote_ip:, params:)
        create = Creators::AssessmentCreator.call(remote_ip:,
                                                  assessment_params: params[:assessment],
                                                  version: CFEConstants::DEFAULT_ASSESSMENT_VERSION)
        if create.success?
          assessment = create.assessment

          errors = CREATE_FUNCTIONS.map { |f|
            f.call(assessment, params)
          }.compact.map(&:errors).reduce([], :+)

          CreationResult.new(errors:, assessment: create.assessment.reload).freeze
        else
          CreationResult.new(errors: create.errors).freeze
        end
      end

      CREATE_FUNCTIONS = [
        lambda { |assessment, params|
          Creators::ProceedingTypesCreator.call(assessment_id: assessment.id,
                                                proceeding_types_params: { proceeding_types: params[:proceeding_types] })
        },
        lambda { |assessment, params|
          Creators::ApplicantCreator.call(assessment_id: assessment.id,
                                          applicant_params: { applicant: params[:applicant] })
        },
        lambda { |assessment, params|
          if params[:dependants]
            Creators::DependantsCreator.call(assessment_id: assessment.id,
                                             dependants_params: { dependants: params[:dependants] })
          end
        },
        lambda { |assessment, params|
          if params[:cash_transactions]
            Creators::CashTransactionsCreator.call(assessment_id: assessment.id,
                                                   cash_transaction_params: params[:cash_transactions])
          end
        },
        lambda { |assessment, params|
          if params[:employment_income]
            Creators::EmploymentsCreator.call(employment_collection: assessment.employments,
                                              employments_params: { employment_income: params[:employment_income] })
          end
        },
        lambda { |assessment, params|
          if params[:irregular_incomes]
            Creators::IrregularIncomeCreator.call(irregular_income_params: params[:irregular_incomes],
                                                  gross_income_summary: assessment.gross_income_summary)
          end
        },
        lambda { |assessment, params|
          if params[:other_incomes]
            Creators::OtherIncomesCreator.call(assessment_id: assessment.id,
                                               other_incomes_params: { other_incomes: params[:other_incomes] })
          end
        },
        lambda { |assessment, params|
          if params[:state_benefits]
            Creators::StateBenefitsCreator.call(assessment_id: assessment.id,
                                                state_benefits_params: { state_benefits: params[:state_benefits] })
          end
        },
        lambda { |assessment, params|
          if params[:vehicles]
            Creators::VehicleCreator.call(assessment_id: assessment.id,
                                          vehicles_params: { vehicles: params[:vehicles] })
          end
        },
        lambda { |assessment, params|
          if params[:capitals]
            Creators::CapitalsCreator.call(assessment_id: assessment.id,
                                           capital_params: params[:capitals])
          end
        },
        lambda { |assessment, params|
          if params[:regular_transactions]
            Creators::RegularTransactionsCreator.call(
              assessment_id: assessment.id,
              regular_transaction_params: { regular_transactions: params[:regular_transactions] },
            )
          end
        },
        lambda { |assessment, params|
          if params[:outgoings]
            Creators::OutgoingsCreator.call(assessment_id: assessment.id,
                                            outgoings_params: { outgoings: params[:outgoings] })
          end
        },
        lambda { |assessment, params|
          if params[:properties]
            Creators::PropertiesCreator.call(assessment_id: assessment.id,
                                             properties_params: { properties: params[:properties] })
          end
        },
        lambda { |assessment, params|
          if params[:partner]
            Creators::PartnerFinancialsCreator.call(assessment_id: assessment.id,
                                                    partner_financials_params: params[:partner])
          end
        },
        lambda { |assessment, params|
          if params[:explicit_remarks]
            Creators::ExplicitRemarksCreator.call(assessment_id: assessment.id,
                                                  explicit_remarks_params: { explicit_remarks: params[:explicit_remarks] })
          end
        },
      ].freeze
    end
  end
end
