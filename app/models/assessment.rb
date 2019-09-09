class Assessment < ApplicationRecord
  validates :remote_ip,
            :submission_date,
            :matter_proceeding_type, presence: true

  has_one :applicant
  has_one :capital_summary

  has_many :benefit_receipts
  has_many :dependants
  has_many :outgoings
  has_many :properties, through: :capital_summary
  has_many :vehicles, through: :capital_summary
  has_many :capital_items, through: :capital_summary
  has_many :wage_slips
  has_one :result

  delegate :capital_assessment_result, :summarise!, :determine_result!, to: :capital_summary
end
