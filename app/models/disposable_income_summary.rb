class DisposableIncomeSummary < ApplicationRecord
  belongs_to :assessment
  has_many :outgoings, class_name: 'Outgoings::BaseOutgoing'
  has_many :childcare_outgoings, class_name: 'Outgoings::Childcare'
  has_many :housing_cost_outgoings, class_name: 'Outgoings::HousingCost'
  has_many :maintenance_outgoings, class_name: 'Outgoings::Maintenance'
end
