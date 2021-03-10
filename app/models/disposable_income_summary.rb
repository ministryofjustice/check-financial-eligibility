class DisposableIncomeSummary < ApplicationRecord
  extend EnumHash
  include MonthlyEquivalentCalculator

  belongs_to :assessment
  has_many :outgoings, dependent: :destroy, class_name: 'Outgoings::BaseOutgoing'
  has_many :childcare_outgoings, dependent: :destroy, class_name: 'Outgoings::Childcare'
  has_many :housing_cost_outgoings, dependent: :destroy, class_name: 'Outgoings::HousingCost'
  has_many :maintenance_outgoings, dependent: :destroy, class_name: 'Outgoings::Maintenance'
  has_many :legal_aid_outgoings, dependent: :destroy, class_name: 'Outgoings::LegalAid'

  delegate :v3?, to: :assessment

  enum(
    assessment_result: enum_hash_for(
      :pending, :eligible, :ineligible, :contribution_required
    ),
    _prefix: false
  )

  def calculate_monthly_childcare_amount!(eligible, cash_amount)
    calculate_monthly_equivalent!(target_field: :child_care_bank,
                                  collection: eligible ? childcare_outgoings : [])
    update!(child_care_cash: eligible ? cash_amount : 0.0)
  end

  def calculate_monthly_rent_or_mortgage_amount!
    monthly_amount = calculate_monthly_equivalent(collection: housing_cost_outgoings,
                                                  amount_method: :allowable_amount)
    update!(rent_or_mortgage_bank: monthly_amount)
  end

  def calculate_monthly_maintenance_amount!
    calculate_monthly_equivalent!(target_field: :maintenance_out_bank,
                                  collection: maintenance_outgoings)
  end

  def calculate_monthly_legal_aid_amount!
    calculate_monthly_equivalent!(target_field: :legal_aid_bank,
                                  collection: legal_aid_outgoings)
  end
end
