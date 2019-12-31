module Outgoings
  class HousingCost < BaseOutgoing
    extend EnumHash

    enum housing_cost_type: enum_hash_for(:rent, :mortgage, :board_and_lodging)
  end
end
