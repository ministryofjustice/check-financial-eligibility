class Property < ApplicationRecord
  belongs_to :capital_summary

  scope :main_home, -> { where(main_home: true) }
  scope :additional, -> { where(main_home: false) }
  scope :disputed, -> { where(subject_matter_of_dispute: true) }
end
