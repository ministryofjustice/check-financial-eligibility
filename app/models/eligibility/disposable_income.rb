module Eligibility
  class DisposableIncome < Base
    belongs_to :disposable_income_summary, inverse_of: :eligibilities, foreign_key: :parent_id
  end
end
