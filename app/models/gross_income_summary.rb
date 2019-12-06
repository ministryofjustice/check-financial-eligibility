class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment

  has_many :employments
  has_many :other_income_sources
end
