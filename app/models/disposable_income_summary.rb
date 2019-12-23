class DisposableIncomeSummary < ApplicationRecord
  extend EnumHash
  belongs_to :assessment
  has_many :childcare_outgoings
  has_many :housing_cost_outgoings
  has_many :maintenance_outgoings

  enum housing_cost_type: enum_hash_for(:rent, :mortgage, :board_and_lodging)
end
