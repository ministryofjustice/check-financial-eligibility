class Applicant < ApplicationRecord
  extend EnumHash

  belongs_to :assessment, optional: true
  delegate :submission_date, to: :assessment, allow_nil: true

  enum involvement_type: enum_hash_for(:applicant)

  validate :date_of_birth_in_past

  def date_of_birth_in_past
    errors.add(:date_of_birth, 'cannot be in future') if date_of_birth > Date.today
  end

  def age_at_submission
    return unless submission_date

    ((submission_date.to_time - date_of_birth.to_time) / 1.year).to_i
  end
end
