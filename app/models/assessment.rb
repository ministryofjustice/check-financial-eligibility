class Assessment < ApplicationRecord
  extend EnumHash

  validates :remote_ip,
            :submission_date,
            :matter_proceeding_type, presence: true

  has_one :applicant
  has_one :capital_summary
  has_one :gross_income_summary

  has_many :dependants
  has_many :outgoings
  has_many :properties, through: :capital_summary
  has_many :vehicles, through: :capital_summary
  has_many :capital_items, through: :capital_summary
  has_many :wage_slips
  has_many :assessment_errors
  has_one :result

  enum matter_proceeding_type: enum_hash_for(:domestic_abuse)

  delegate :capital_assessment_result, :determine_result!, to: :capital_summary
end
