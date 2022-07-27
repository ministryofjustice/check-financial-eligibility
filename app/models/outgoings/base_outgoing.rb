module Outgoings
  class BaseOutgoing < ApplicationRecord
    belongs_to :disposable_income_summary

    self.table_name = "outgoings"

    validates :payment_date, cfe_date: { not_in_the_future: true }
  end
end
