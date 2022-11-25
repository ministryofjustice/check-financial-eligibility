module Eligibility
  class Capital < Base
    validates :upper_threshold, :lower_threshold, presence: true

    belongs_to :capital_summary, inverse_of: :eligibilities, foreign_key: :parent_id

    def update_assessment_result!(assessed_capital)
      update!(assessment_result: assessed_result(assessed_capital))
    end

  private

    def assessed_result(assessed_capital)
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
