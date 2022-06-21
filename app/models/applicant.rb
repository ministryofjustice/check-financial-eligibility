class Applicant < ApplicationRecord
  extend EnumHash
  include Person

  belongs_to :assessment, optional: true
  delegate :submission_date, to: :assessment, allow_nil: true

  enum involvement_type: enum_hash_for(:applicant)

  validate :date_of_birth_in_past

  def date_of_birth_in_past
    errors.add(:date_of_birth, "cannot be in future") if date_of_birth > Date.current
  end
end
