class Dependant < ApplicationRecord
  extend EnumHash
  belongs_to :assessment

  enum relationship: enum_hash_for(:child_relative, :adult_relative)

  validates :date_of_birth, comparison: { less_than_or_equal_to: Date.current }

  def becomes_adult_on
    date_of_birth.years_since(16)
  end
end
