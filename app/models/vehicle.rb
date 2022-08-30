class Vehicle < ApplicationRecord
  delegate :assessment, to: :capital_summary
  delegate :submission_date, to: :assessment

  belongs_to :capital_summary

  validates :date_of_purchase, cfe_date: { not_in_the_future: true }

  def assess!
    in_regular_use? ? assess_vehicle_in_regular_use : assess_vehicle_not_in_regular_use
    save!
  end

private

  def assess_vehicle_not_in_regular_use
    self.included_in_assessment = true
    self.assessed_value = value
  end

  def assess_vehicle_in_regular_use
    net_value = value - loan_amount_outstanding
    if vehicle_age_in_months >= vehicle_out_of_scope_age || net_value <= vehicle_disregard
      self.included_in_assessment = false
      self.assessed_value = 0
    else
      self.included_in_assessment = true
      self.assessed_value = net_value - vehicle_disregard
    end
  end

  def vehicle_age_in_months
    Calculators::VehicleAgeCalculator.new(date_of_purchase, submission_date).in_months
  end

  def vehicle_out_of_scope_age
    Threshold.value_for(:vehicle_out_of_scope_months, at: submission_date)
  end

  def vehicle_disregard
    Threshold.value_for(:vehicle_disregard, at: submission_date)
  end
end
