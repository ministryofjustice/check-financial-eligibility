class GrossIncomeSummary < ApplicationRecord
  belongs_to :assessment

  has_many :employments
end
