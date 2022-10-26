class Applicant < ApplicationRecord
  extend EnumHash

  belongs_to :assessment, optional: true
  delegate :submission_date, to: :assessment, allow_nil: true

  enum involvement_type: enum_hash_for(:applicant)

  validates :date_of_birth, comparison: { less_than_or_equal_to: Date.current }
end
