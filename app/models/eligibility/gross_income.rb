module Eligibility
  class GrossIncome < Base
    validates :upper_threshold, presence: true
    validates :lower_threshold, absence: true

    belongs_to :gross_income_summary, inverse_of: :eligibilities, foreign_key: :parent_id

    delegate :total_gross_income, to: :gross_income_summary

    def update_assessment_result!
      update!(assessment_result: assessed_result)
    end

  private

    def assessed_result
      total_gross_income < upper_threshold ? "eligible" : "ineligible"
    end
  end
end
