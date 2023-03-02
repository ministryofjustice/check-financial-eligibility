class Vehicle < ApplicationRecord
  delegate :assessment, to: :capital_summary
  delegate :submission_date, to: :assessment

  belongs_to :capital_summary

  validates :date_of_purchase, date: {
    before: proc { Time.zone.tomorrow }, message: :not_in_the_future
  }

  scope :disputed, -> { where(subject_matter_of_dispute: true) }
end
