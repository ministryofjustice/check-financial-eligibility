class PersonCapitalSubtotals
  def initialize(data = {})
    @total_vehicle = data[:total_vehicle]
    @assessed_capital = data[:assessed_capital]
    @assessment_result = data[:assessment_result]
    @total_capital = data[:total_capital]
    @total_liquid = data[:total_liquid]
    @total_mortgage_allowance = data[:total_mortgage_allowance]
    @total_non_liquid = data[:total_non_liquid]
    @total_property = data[:total_property]
    @subject_matter_of_dispute_disregard = data[:subject_matter_of_dispute_disregard]
    @pensioner_capital_disregard = data[:pensioner_capital_disregard]
  end

  attr_reader :total_vehicle,
              :assessed_capital,
              :assessment_result,
              :total_capital,
              :total_liquid,
              :total_mortgage_allowance,
              :total_non_liquid,
              :total_property,
              :subject_matter_of_dispute_disregard,
              :pensioner_capital_disregard
end
