module Eligibility
  class GrossIncome < Base
    validates :upper_threshold, presence: true
    validates :lower_threshold, absence: true

    belongs_to :gross_income_summary, inverse_of: :eligibilities, foreign_key: :parent_id

    def update_assessment_result!(total_gross_income)
      update!(assessment_result: assessed_result(total_gross_income))
    end

  private

    def assessed_result(total_gross_income)
      total_gross_income < upper_threshold ? "eligible" : "ineligible"
    end
  end
end
