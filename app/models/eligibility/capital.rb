module Eligibility
  class Capital < Base
    belongs_to :capital_summary, inverse_of: :eligibilities, foreign_key: :parent_id

    delegate :assessed_capital, to: :capital_summary

    def update_assessment_result!
      update!(assessment_result: assessed_result)
    end

    private

    def assessed_result
      if assessed_capital <= lower_threshold
        :eligible
      elsif assessed_capital <= upper_threshold
        :contribution_required
      else
        :ineligible
      end
    end
  end
end
