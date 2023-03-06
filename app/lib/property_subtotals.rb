class PropertySubtotals
  delegate :value, :outstanding_mortgage, :percentage_owned, :assessed_equity,
           :net_value, :net_equity, :main_home_equity_disregard, :smod_allowance,
           :transaction_allowance, :main_home, :shared_with_housing_assoc, to: :@result

  DummyResult = Struct.new :value, :outstanding_mortgage, :percentage_owned, :assessed_equity,
                           :net_value, :net_equity, :main_home_equity_disregard, :smod_allowance,
                           :transaction_allowance, :main_home, :shared_with_housing_assoc, keyword_init: true

  def initialize(result = DummyResult.new(value: 0.0, outstanding_mortgage: 0.0, percentage_owned: 0,
                                          assessed_equity: 0.0, net_value: 0.0, net_equity: 0.0,
                                          main_home_equity_disregard: 0.0, smod_allowance: 0.0,
                                          transaction_allowance: 0.0,
                                          main_home: false, shared_with_housing_assoc: false))
    @result = result
  end
end
