class Assessment < ApplicationRecord
  validates :remote_ip,
            :submission_date,
            :matter_proceeding_type,
            :client_reference_id, presence: true

  has_many :dependents
  has_many :properties
  has_many :wage_slips
  has_many :benefit_receipts
end
