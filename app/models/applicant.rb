class Applicant < ApplicationRecord
  belongs_to :assessment, optional: true

  validate :date_of_birth_in_past

  def date_of_birth_in_past
    errors.add(:date_of_birth, 'cannot be in future') if date_of_birth > Date.today
  end
end
