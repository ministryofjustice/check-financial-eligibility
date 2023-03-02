module Outgoings
  class BaseOutgoing < ApplicationRecord
    belongs_to :disposable_income_summary

    self.table_name = "outgoings"

    validates :payment_date, date: {
      before: proc { Time.zone.tomorrow }, message: :not_in_the_future
    }
  end
end
