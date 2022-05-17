class CapitalItem < ApplicationRecord
  belongs_to :capital_summary

  validates :description, presence: true
  validates :type, presence: true
  validates :value, presence: true, currency: {}
end
