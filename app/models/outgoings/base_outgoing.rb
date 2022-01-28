module Outgoings
  class BaseOutgoing < ApplicationRecord
    belongs_to :disposable_income_summary

    self.table_name = "outgoings"
  end
end
