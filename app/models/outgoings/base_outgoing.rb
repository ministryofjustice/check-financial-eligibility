module Outgoings
  class BaseOutgoing < ApplicationRecord
    belongs_to :disposable_income_summary
  end
end

