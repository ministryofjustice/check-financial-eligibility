class Applicant < ApplicationRecord
  extend EnumHash

  belongs_to :assessment, optional: true
  delegate :submission_date, to: :assessment, allow_nil: true

  enum involvement_type: enum_hash_for(:applicant)

  validate :date_of_birth_in_past
  validates :date_of_birth, presence: true
  validates :has_partner_opponent, inclusion: { in: [true, false] }
  validates :receives_qualifying_benefit, inclusion: { in: [true, false] }
  validates :involvement_type, presence: true, inclusion: Applicant.involvement_types.values

  def date_of_birth_in_past
    errors.add(:date_of_birth, "cannot be in future") if date_of_birth > Date.current
  end

  def age_at_submission
    return unless submission_date

    ((submission_date.to_time - date_of_birth.to_time) / 1.year).to_i
  end
end
