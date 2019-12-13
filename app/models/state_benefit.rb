class StateBenefit < ApplicationRecord
  belongs_to :gross_income_summary
  belongs_to :state_benefit_type
  has_many :state_benefit_payments

  validates :gross_income_summary_id, :state_benefit_type, presence: true

  def self.generate!(gross_income_summary, name)
    StateBenefitType.exists?(label: name) ? generate_for(gross_income_summary, name) : generate_other(gross_income_summary, name)
  end

  def self.generate_for(gross_income_summary, name)
    create!(
      gross_income_summary: gross_income_summary,
      state_benefit_type: StateBenefitType.find_by(label: name)
    )
  end

  def self.generate_other(gross_income_summary, name)
    create!(
      gross_income_summary: gross_income_summary,
      state_benefit_type: StateBenefitType.find_by(label: 'other'),
      name: name
    )
  end
end
