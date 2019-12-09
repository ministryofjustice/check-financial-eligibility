class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment

  has_many :other_income_sources
end
