class EmploymentPayment < ApplicationRecord
  belongs_to :employment

  attribute :net_income
  before_validation :set_net_income
  validates :net_income, numericality: { greater_than_or_equal_to: 0 }

private

  def set_net_income
    self.net_income = gross_income + benefits_in_kind + tax + national_insurance
  end
end
