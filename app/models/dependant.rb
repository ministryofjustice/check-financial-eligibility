class Dependant < ApplicationRecord
  extend EnumHash
  include Person

  belongs_to :assessment
  delegate :submission_date, to: :assessment, allow_nil: true

  enum relationship: enum_hash_for(:child_relative, :adult_relative)

  validate :date_of_birth_in_past

  def date_of_birth_in_past
    errors.add(:date_of_birth, "cannot be in future") if date_of_birth > Date.current
  end
end
