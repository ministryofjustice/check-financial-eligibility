class PersonCapitalSubtotals
  def initialize(data = Hash.new(0.0))
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
    @pensioner_disregard_applied = data[:pensioner_disregard_applied]
    @total_capital_with_smod = data[:total_capital_with_smod]
    @main_home = data.fetch(:main_home, PropertySubtotals.new)
    @additional_properties = data.fetch(:additional_properties, [])
    @disputed_non_property_disregard = data[:disputed_non_property_disregard]
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
              :pensioner_capital_disregard,
              :main_home,
              :additional_properties,
              :pensioner_disregard_applied,
              :total_capital_with_smod,
              :disputed_non_property_disregard
end
