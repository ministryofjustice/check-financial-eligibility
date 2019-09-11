class Property < ApplicationRecord
  belongs_to :capital_summary

  delegate :assessment, to: :capital_summary
  delegate :submission_date, to: :assessment

  def assess_equity!(remaining_mortgage_allowance)
    calculate_property_transaction_allowance
    calculate_outstanding_mortgage(remaining_mortgage_allowance)
    calculate_net_value
    calculate_net_equity
    calculate_main_home_disregard
    calculate_assessed_equity
    save!
  end

  def result # rubocop:disable Metrics/AbcSize
    {
      value: value.to_f,
      transaction_allowance: transaction_allowance.to_f,
      allowable_outstanding_mortgage: allowable_outstanding_mortgage.to_f,
      net_value: net_value.to_f,
      percentage_share: percentage_owned.to_f,
      net_equity: net_equity.to_f,
      main_home_equity_disregard: main_home_equity_disregard.to_f,
      assessed_equity: assessed_equity.to_f
    }
  end

  private

  def calculate_property_transaction_allowance
    self.transaction_allowance = (value * notional_transaction_cost_pctg).round(2)
  end

  def notional_transaction_cost_pctg
    Threshold.value_for(:property_notional_sale_costs_percentage, at: submission_date) / 100.0
  end

  def calculate_outstanding_mortgage(remaining_mortgage_allowance)
    self.allowable_outstanding_mortgage = allowable_mortgage_deduction(remaining_mortgage_allowance)
  end

  def allowable_mortgage_deduction(remaining_mortgage_allowance)
    outstanding_mortgage > remaining_mortgage_allowance ? remaining_mortgage_allowance : outstanding_mortgage
  end

  def calculate_net_value
    self.net_value = value - transaction_allowance - allowable_outstanding_mortgage
  end

  def calculate_net_equity
    self.net_equity = (net_value * shared_ownership_percentage).round(2)
  end

  def shared_ownership_percentage
    percentage_owned / 100.0
  end

  def calculate_main_home_disregard
    self.main_home_equity_disregard = Threshold.value_for(:property_disregard, at: submission_date)[property_type]
  end

  def property_type
    main_home ? :main_home : :additional_property
  end

  def calculate_assessed_equity
    self.assessed_equity = net_equity - main_home_equity_disregard
  end
end
