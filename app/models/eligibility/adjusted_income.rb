module Eligibility
  class AdjustedIncome < CrimeBase
    validates :lower_threshold, :upper_threshold, presence: true

    belongs_to :gross_income_summary, inverse_of: :crime_eligibilities, foreign_key: :parent_id
  end
end
