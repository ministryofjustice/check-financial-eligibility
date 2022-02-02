module TestCase
  class Result
    def initialize(expected_result, actual_result, verbosity_level)
      @expected = expected_result
      @actual = actual_result
      @verbosity_level = verbosity_level
      @header_pattern = "%58s  %-23s %-23s"
      @overall_result = true
    end

    def compare
      print_result_headings
      @expected.result_set.each_key do |key|
        next if key == "assessment_passported"

        compare_and_print_result(key)
      end
      @overall_result
    end

  private

    def compare_and_print_result(key)
      if ignorable?(expected_value(key))
        print_ignored_result(key)
      elsif expected_value(key) != actual_value(key)
        print_error_result(key)
      else
        print_result(key, :green)
      end
    end

    def print_ignored_result(key)
      print_result(key, :blue)
    end

    def print_error_result(key)
      @overall_result = false
      print_result(key, :red)
    end

    def expected_value(key)
      @expected.result_set[key]
    end

    def actual_value(key)
      __send__(key)
    end

    def ignorable?(expected_value)
      expected_value.nil? || expected_value == "" || expected_value == "n/a"
    end

    def print_result_headings
      return if @verbosity_level.zero?

      puts sprintf(@header_pattern, assessment[:client_reference_id], "Expected", "Actual")
      puts sprintf(@header_pattern, "", "=========", "=========")
    end

    def print_result(key, color)
      return if @verbosity_level.zero?

      puts sprintf(@header_pattern, key, @expected.result_set[key], __send__(key)).__send__(color)
    end

    def assessment
      @actual[:assessment]
    end

    def applicant
      assessment[:applicant]
    end

    def gross_income
      assessment[:gross_income]
    end

    def gross_income_summary
      gross_income[:summary]
    end

    def other_income
      gross_income[:other_income]
    end

    def other_income_all_sources
      other_income[:monthly_equivalents][:all_sources]
    end

    def disposable_income
      assessment[:disposable_income]
    end

    def disposable_income_all_sources
      disposable_income[:monthly_equivalents][:all_sources]
    end

    def deductions
      disposable_income[:deductions]
    end

    def capital
      assessment[:capital]
    end

    def state_benefits
      gross_income[:state_benefits][:monthly_equivalents]
    end

    def irregular_income
      gross_income[:irregular_income][:monthly_equivalents]
    end

    def assessment_passported
      assessment[:passported]
    end

    def assessment_assessment_result
      assessment[:assessment_result]
    end

    def gross_income_summary_monthly_other_income
      other_income_all_sources.values.sum(&:to_f)
    end

    def gross_income_summary_monthly_student_loan
      irregular_income[:student_loan].to_f
    end

    def gross_income_summary_upper_threshold
      gross_income_summary[:upper_threshold].to_f
    end

    def gross_income_summary_monthly_state_benefits
      state_benefits[:all_sources].to_f
    end

    def gross_income_summary_total_gross_income
      gross_income_summary[:total_gross_income].to_f
    end

    def gross_income_summary_assessment_result
      gross_income_summary[:assessment_result]
    end

    def disposable_income_summary_childcare
      disposable_income_all_sources[:child_care].to_f
    end

    def disposable_income_summary_dependant_allowance
      deductions[:dependants_allowance].to_f
    end

    def disposable_income_summary_maintenance
      disposable_income_all_sources[:maintanance_out].to_f
    end

    def disposable_income_summary_gross_housing_costs
      disposable_income[:gross_housing_costs].to_f
    end

    def disposable_income_summary_housing_benefit
      disposable_income[:housing_benefit].to_f
    end

    def disposable_income_summary_net_housing_costs
      disposable_income[:net_housing_costs].to_f
    end

    def disposable_income_summary_legal_aid
      disposable_income[:legal_aid].to_f
    end

    def disposable_income_summary_total_outgoings_and_allowances
      disposable_income[:total_outgoings_and_allowances].to_f
    end

    def disposable_income_summary_total_disposable_income
      disposable_income[:total_disposable_income].to_f
    end

    def disposable_income_summary_lower_threshold
      disposable_income[:lower_threshold].to_f
    end

    def disposable_income_summary_upper_threshold
      disposable_income[:upper_threshold].to_f
    end

    def disposable_income_summary_assessment_result
      disposable_income[:assessment_result]
    end

    def disposable_income_summary_income_contribution
      disposable_income[:income_contribution].to_f
    end

    def capital_total_liquid
      capital[:total_liquid].to_f
    end

    def capital_total_non_liquid
      capital[:total_non_liquid].to_f
    end

    def capital_total_vehicle
      capital[:total_vehicle].to_f
    end

    def capital_total_mortgage_allowance
      capital[:total_mortgage_allowance].to_f
    end

    def capital_total_capital
      capital[:total_capital].to_f
    end

    def capital_pensioner_capital_disregard
      capital[:pensioner_capital_disregard].to_f
    end

    def capital_assessed_capital
      capital[:assessed_capital].to_f
    end

    def capital_lower_threshold
      capital[:lower_threshold].to_f
    end

    def capital_upper_threshold
      capital[:upper_threshold].to_f
    end

    def capital_assessment_result
      capital[:assessment_result]
    end

    def capital_capital_contribution
      capital[:capital_contribution].to_f
    end

    def monthly_income_equivalents_friends_or_family
      other_income_all_sources[:friends_or_family].to_f
    end

    def monthly_income_equivalents_maintenance_in
      other_income_all_sources[:maintenance_in].to_f
    end

    def monthly_income_equivalents_property_or_lodger
      other_income_all_sources[:property_or_lodger].to_f
    end

    def monthly_income_equivalents_student_loan
      gross_income_summary_monthly_student_loan
    end

    def monthly_income_equivalents_pension
      other_income_all_sources[:pension].to_f
    end

    def monthly_outgoing_equivalents_maintenance_out
      disposable_income_all_sources[:maintenance_out].to_f
    end

    def monthly_outgoing_equivalents_child_care
      disposable_income_all_sources[:child_care].to_f
    end

    def monthly_outgoing_equivalents_rent_or_mortgage
      disposable_income_all_sources[:rent_or_mortgage].to_f
    end

    def monthly_outgoing_equivalents_legal_aid
      disposable_income_all_sources[:legal_aid].to_f
    end

    def deductions_dependants_allowance
      deductions[:dependants_allowance].to_f
    end

    def deductions_disregarded_state_benefits
      deductions[:disregarded_state_benefits].to_f
    end
  end
end
