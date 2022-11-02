class CapitalItem < ApplicationRecord
  belongs_to :capital_summary
  scope :disputed, -> { where(subject_matter_of_dispute: true) }
end
