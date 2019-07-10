class WageSlip < ApplicationRecord
  belongs_to :assessment

  alias_attribute :national_insurance_contribution, :nic
end
