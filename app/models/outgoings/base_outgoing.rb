module Outgoings
  class BaseOutgoing < ApplicationRecord
    include DefaultClientId

    belongs_to :disposable_income_summary

    self.table_name = 'outgoings'
  end
end
