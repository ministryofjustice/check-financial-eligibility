class Employment < ApplicationRecord
  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy

  validates :calculation_method, inclusion: { in: %w[blunt_average most_recent] }, allow_nil: true
end
