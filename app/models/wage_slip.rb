class WageSlip < ApplicationRecord
  extend PaymentPatternConcern
  define_payment_pattern currency_field: :gross_pay

  belongs_to :assessment

  alias_attribute :national_insurance_contribution, :nic
end
