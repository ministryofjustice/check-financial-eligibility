class CapitalItem < ApplicationRecord
  belongs_to :capital_summary

  def result
    { description => value.to_f }
  end
end
