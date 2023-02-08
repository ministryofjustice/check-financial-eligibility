class StateBenefit < ApplicationRecord
  belongs_to :gross_income_summary
  belongs_to :state_benefit_type
  has_many :state_benefit_payments, dependent: :destroy

  delegate :exclude_from_gross_income, :exclude_from_gross_income?, to: :state_benefit_type
  delegate :assessment, to: :gross_income_summary

  def self.generate!(gross_income_summary, name)
    StateBenefitType.exists?(label: name) ? generate_for(gross_income_summary, name) : generate_other(gross_income_summary, name)
  end

  def self.generate_for(gross_income_summary, name)
    create!(
      gross_income_summary:,
      state_benefit_type: StateBenefitType.find_by(label: name),
    )
  end

  def self.generate_other(gross_income_summary, name)
    create!(
      gross_income_summary:,
      state_benefit_type: StateBenefitType.find_by(label: "other"),
      name:,
    )
  end

  def state_benefit_name
    name.nil? ? state_benefit_type.name : name
  end
end
