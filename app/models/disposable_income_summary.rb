class DisposableIncomeSummary < ApplicationRecord
  extend EnumHash
  belongs_to :assessment

  enum housing_cost_type: enum_hash_for(:rent, :mortgage, :board_and_lodging)
end
