class Employment < ApplicationRecord
  belongs_to :gross_income_summary

  has_many :wage_payments
  has_many :benefit_in_kinds
end
