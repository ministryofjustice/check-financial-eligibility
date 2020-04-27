class DisposableIncomeSummary < ApplicationRecord
  extend EnumHash
  include MonthlyEquivalentCalculator

  belongs_to :assessment
  has_many :outgoings, class_name: 'Outgoings::BaseOutgoing'
  has_many :childcare_outgoings, class_name: 'Outgoings::Childcare'
  has_many :housing_cost_outgoings, class_name: 'Outgoings::HousingCost'
  has_many :maintenance_outgoings, class_name: 'Outgoings::Maintenance'
  has_many :legal_aid_outgoings, class_name: 'Outgoings::LegalAid'

  enum(
    assessment_result: enum_hash_for(
      :pending, :eligible, :ineligible, :contribution_required
    ),
    _prefix: false
  )

  def calculate_monthly_childcare_amount!
    calculate_monthly_equivalent!(target_field: :childcare,
                                  collection: childcare_outgoings)
  end

  def calculate_monthly_maintenance_amount!
    calculate_monthly_equivalent!(target_field: :maintenance,
                                  collection: maintenance_outgoings)
  end

  def calculate_monthly_legal_aid_amount!
    calculate_monthly_equivalent!(target_field: :legal_aid,
                                  collection: legal_aid_outgoings)
  end
end
