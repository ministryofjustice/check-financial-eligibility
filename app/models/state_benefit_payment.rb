class StateBenefitPayment < ApplicationRecord
  include DefaultClientId

  belongs_to :state_benefit
end
