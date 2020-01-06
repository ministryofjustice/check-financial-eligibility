class DisposableIncomeSummary < ApplicationRecord
  include MonthlyEquivalentCalculator

  belongs_to :assessment
  has_many :outgoings, class_name: 'Outgoings::BaseOutgoing'
  has_many :childcare_outgoings, class_name: 'Outgoings::Childcare'
  has_many :housing_cost_outgoings, class_name: 'Outgoings::HousingCost'
  has_many :maintenance_outgoings, class_name: 'Outgoings::Maintenance'

  def calculate_monthly_childcare_amount!
    calculate_monthly_equivalent!(target_field: :childcare,
                                  collection: childcare_outgoings)
  end

  def calculate_monthly_maintenance_amount!
    calculate_monthly_equivalent!(target_field: :maintenance,
                                  collection: maintenance_outgoings)
  end
end
