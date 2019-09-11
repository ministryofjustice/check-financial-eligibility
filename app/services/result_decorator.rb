class ResultDecorator
  attr_reader :assessment
  delegate :applicant, :capital_summary, to: :assessment

  def initialize(assessment)
    @assessment = assessment
  end

  def as_json(_options = nil)
    {
      assessment_result: assessment.capital_assessment_result,
      applicant: applicant_hash,
      capital: capital_hash,
      property: property_hash,
      vehicles: vehicles_hash
    }
  end

  def applicant_hash
    applicant.as_json(methods: :age_at_submission, only: :receives_qualifying_benefit)
  end

  def capital_hash
    capital_summary.as_json(
      only: [
        :total_capital, :pensioner_capital_disregard, :capital_contribution, :total_liquid, :total_non_liquid,
      ],
      include: [
        liquid_capital_items: { only: [:description, :value] },
        non_liquid_capital_items: { only: [:description, :value] }
      ]
    )
  end

  def property_hash
    main_property_attrs = [:value, :transaction_allowance, :allowable_outstanding_mortgage, :percentage_owned, :assessed_equity]
    capital_summary.as_json(
      only: [:total_property, :total_mortgage_allowance],
      include: [
        main_home: {
          only: (main_property_attrs + [:shared_with_housing_assoc, :net_equity, :main_home_equity_disregard])
        },
        additional_properties: {
          only: main_property_attrs
        }
      ]
    )
  end

  def vehicles_hash
    capital_summary.as_json(
      only: [:total_vehicle],
      include: [
        vehicles: {
          only: [
            :date_of_purchase, :assessed_value, :loan_amount_outstanding, :in_regular_use, :included_in_assessment, :value
          ]
        }
      ]
    )
  end
end
