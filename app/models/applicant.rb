class Applicant < ApplicationRecord
  belongs_to :assessment, optional: true

  validate :date_of_birth_in_past

  def date_of_birth_in_past
    errors.add(:date_of_birth, 'cannot be in future') if date_of_birth > Date.today
  end

  def age_in_years
    age = assessment.submission_date.year - date_of_birth.year
    age -= 1 if assessment.submission_date < date_of_birth + age.years
    age
  end
end
