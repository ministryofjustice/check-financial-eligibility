class Assessment < ApplicationRecord
  extend EnumHash

  validates :remote_ip,
            :submission_date,
            :matter_proceeding_type, presence: true

  has_one :applicant
  has_one :capital_summary
  has_one :gross_income_summary
  has_one :disposable_income_summary

  has_many :dependants
  has_many :properties, through: :capital_summary
  has_many :vehicles, through: :capital_summary
  has_many :capital_items, through: :capital_summary
  has_many :assessment_errors

  enum matter_proceeding_type: enum_hash_for(:domestic_abuse)

  delegate :determine_result!, to: :capital_summary

  def capital_assessment_result
    capital_summary.assessment_result
  end
end
