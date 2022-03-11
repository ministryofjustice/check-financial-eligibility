require_relative "remarks_comparer"

module TestCase
  module V4
    class ResultComparer
      def self.call(actual, expected, verbosity)
        new(actual, expected, verbosity).call
      end

      def initialize(actual, expected, verbosity)
        @actual = actual
        @expected = expected
        @verbosity = verbosity
        @result = true
        @header_pattern = "%58s  %-26s %-s"
      end

      def call
        print_headings
        compare_assessment
        compare_matter_types
        compare_proceeding_types
        compare_gross_income
        compare_disposable_income
        compare_capital
        @result = false if RemarksComparer.call(@expected[:remarks], @actual[:assessment][:remarks], @verbosity) == false
        @result
      end

    private

      def silent?
        # @verbosity.zero?
        false
      end

      def print_headings
        verbose sprintf(@header_pattern, client_reference_id, "Expected", "Actual")
        verbose sprintf(@header_pattern, "", "=========", "=========")
      end

      def print_mismatched_matter_types
        verbose "Matter type names do not match expected", :red
        verbose "  Expected: #{expected_matter_type_names.join(', ')}", :red
        verbose "  Actual  : #{actual_matter_type_names.join(', ')}", :red
      end

      def print_mismatched_proceeding_type_codes
        verbose "Proceeding type codes do not match expected", :red
        verbose "  Expected: #{expected_proceeding_type_codes.join(', ')}", :red
        verbose "  Actual  : #{actual_proceeding_type_codes.join(', ')}", :red
      end

      def print_matter_type_details
        expected_matter_types.each do |matter_type_hash|
          name = matter_type_hash.keys.first
          expected_result = matter_type_hash[name]
          actual_result = actual_matter_type_result_for(name)
          color = actual_result == expected_result ? :green : :red
          verbose sprintf(@header_pattern, "Matter type: #{name}", expected_result, actual_result), color
        end
      end

      def client_reference_id
        @actual[:assessment][:client_reference_id]
      end

      def compare_assessment
        compare_and_print("assessment_result", actual_overall_result[:result], expected_assessment[:assessment_result])
      end

      def compare_matter_types
        if expected_matter_type_names == actual_matter_type_names
          print_matter_type_details
        else
          print_mismatched_matter_types
        end
      end

      def compare_proceeding_types
        if actual_proceeding_type_codes == expected_proceeding_type_codes
          expected_proceeding_types.each { |code, expected_result_hash| compare_proceeding_type_detail(code, expected_result_hash) }
        else
          print_mismatched_proceeding_type_codes
        end
      end

      def compare_proceeding_type_detail(code, expected_result_hash)
        verbose "Proceeding_type #{code}", :green
        compare_and_print("result", actual_proceeding_type_result(code), expected_result_hash[:result])
        compare_and_print("capital lower threshold", actual_cap_result_for(code)[:lower_threshold], expected_result_hash[:capital_lower_threshold])
        compare_and_print("capital upper threshold", actual_cap_result_for(code)[:upper_threshold], expected_result_hash[:capital_upper_threshold])
        compare_and_print("gross income upper threshold", actual_gross_income_result_for(code)[:upper_threshold], expected_result_hash[:gross_income_upper_threshold])
        compare_and_print("disposable income lower threshold", actual_disposable_income_result_for(code)[:lower_threshold],
                          expected_result_hash[:disposable_income_lower_threshold])
        compare_and_print("disposable income upper threshold", actual_disposable_income_result_for(code)[:upper_threshold],
                          expected_result_hash[:disposable_income_upper_threshold])
      end

      def compare_and_print(legend, actual, expected)
        color = :green
        color = :red unless actual.to_s == expected.to_s
        color = :blue if expected.nil?
        verbose sprintf(@header_pattern, legend, expected, actual), color
      end

      def compare_gross_income
        puts "Gross income >>>>>>>>>>>>>>>>>>>>>>>>>".green unless silent?
        compare_and_print("monthly other income", actual_gross_other_income, expected_gi_other_income)
        compare_and_print("monthly state benefits", actual_gross_state_benefits, expected_gi_state_benefits)
        compare_and_print("monthly student loan", actual_student_loan, expected_gi_student_loan)
        compare_and_print("employment_income_gross", actual_employment_income[:gross_income], expected_employment_income_gross)
        compare_and_print("employment_income_benefits_in_kind", actual_employment_income[:benefits_in_kind], expected_employment_income_benefits_in_kind)
        compare_and_print("employment_income_tax",  actual_employment_income[:tax], expected_employment_income_tax)
        compare_and_print("employment_income_nic",  actual_employment_income[:national_insurance], expected_employment_income_nic)
        compare_and_print("fixed_employment_allowance", actual_employment_income[:fixed_employment_deduction], expected_fixed_employment_allowance)
        compare_and_print("total gross income", actual_total_gross_income, expected_total_gross_income)
      end

      def compare_disposable_income
        puts "Disposable income >>>>>>>>>>>>>>>>>>>>>>".green unless silent?
        compare_and_print("childcare", actual_disposable(:child_care), expected_disposable(:childcare))
        compare_and_print("dependant allowance", actual_dependant_allowance, expected_disposable(:dependant_allowance))
        compare_and_print("maintenance", actual_disposable(:maintenance_out), expected_disposable(:maintenance))
        compare_and_print("gross_housing_costs", actual_disposable(:rent_or_mortgage), expected_disposable(:gross_housing_costs))
        compare_and_print("housing benefit", disposable_income_result[:housing_benefit], expected_disposable(:housing_benefit))
        compare_and_print("net housing costs", disposable_income_result[:net_housing_costs], expected_disposable(:net_housing_costs))
        compare_and_print("total outgoings and allowances", disposable_income_result[:total_outgoings_and_allowances], expected_disposable(:total_outgoings_and_allowances))
        compare_and_print("total disposable income", disposable_income_result[:total_disposable_income], expected_disposable(:total_disposable_income))
        compare_and_print("income contribution", disposable_income_result[:income_contribution], expected_disposable(:income_contribution))
      end

      def compare_capital
        puts "Capital >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".green unless silent?
        expected_capital.each do |key, value|
          compare_and_print(key, actual_capital[key], value)
        end
      end

      def verbose(string, color = :green)
        puts string.__send__(color) unless silent?
        @result = false if color == :red
      end

      def actual_result_summary
        @actual[:result_summary]
      end

      def actual_overall_result
        actual_result_summary[:overall_result]
      end

      def actual_matter_types
        actual_overall_result[:matter_types]
      end

      def actual_matter_type_names
        actual_matter_types.pluck(:matter_type).sort
      end

      def actual_matter_type_result_for(matter_type_name)
        hash = actual_matter_types.detect { |h| h[:matter_type] == matter_type_name.to_s }
        hash[:result]
      end

      def actual_proceeding_types
        actual_overall_result[:proceeding_types]
      end

      def actual_proceeding_type_codes
        actual_proceeding_types.map { |h| h.fetch(:ccms_code) }.sort
      end

      def actual_proceeding_type_result(code)
        actual_proceeding_types.detect { |h| h[:ccms_code] == code }[:result]
      end

      def actual_cap_result
        @actual[:result_summary][:capital]
      end

      def actual_cap_proceeding_types
        actual_cap_result[:proceeding_types]
      end

      def actual_cap_result_for(code)
        actual_cap_proceeding_types.detect { |h| h[:ccms_code] == code }
      end

      def actual_gross_income_result
        @actual[:result_summary][:gross_income]
      end

      def actual_gross_income_proceeding_types
        actual_gross_income_result[:proceeding_types]
      end

      def actual_gross_income_result_for(code)
        actual_gross_income_proceeding_types.detect { |h| h[:ccms_code] == code }
      end

      def actual_disposable_income_result
        @actual[:result_summary][:disposable_income]
      end

      def actual_disposable_income_proceeding_types
        actual_disposable_income_result[:proceeding_types]
      end

      def actual_disposable_income_result_for(code)
        actual_disposable_income_proceeding_types.detect { |h| h[:ccms_code] == code }
      end

      def actual_gross_income
        @actual[:assessment][:gross_income]
      end

      def actual_gross_other_income
        actual_gross_income[:other_income][:monthly_equivalents][:all_sources].values.sum(&:to_f)
      end

      def actual_gross_state_benefits
        actual_gross_income[:state_benefits][:monthly_equivalents][:all_sources]
      end

      def actual_student_loan
        actual_gross_income[:irregular_income][:monthly_equivalents][:student_loan]
      end

      def actual_total_gross_income
        actual_result_summary[:gross_income][:total_gross_income]
      end

      def actual_disposable_income
        @actual[:assessment][:disposable_income]
      end

      def actual_disposable(key)
        actual_disposable_income[:monthly_equivalents][:all_sources][key]
      end

      def actual_dependant_allowance
        actual_disposable_income[:deductions][:dependants_allowance]
      end

      def disposable_income_result
        @actual[:result_summary][:disposable_income]
      end

      def actual_housing_benefit
        disposable_income_result[:housing_benefit]
      end

      def actual_net_housing_costs
        disposable_income_result[:net_housing_costs]
      end

      def actual_capital
        @actual[:result_summary][:capital]
      end

      def actual_employment_income
        disposable_income_result[:employment_income]
      end

      def expected_assessment
        @expected[:assessment]
      end

      def expected_matter_types
        expected_assessment[:matter_types]
      end

      def expected_matter_type_names
        @expected[:assessment][:matter_types].map(&:keys).flatten.sort.map(&:to_s)
      end

      def expected_proceeding_types
        expected_assessment[:proceeding_types]
      end

      def expected_proceeding_type_codes
        expected_proceeding_types.keys.sort
      end

      def expected_gross_income
        @expected[:gross_income_summary]
      end

      def expected_gi_other_income
        expected_gross_income[:monthly_other_income]
      end

      def expected_gi_state_benefits
        expected_gross_income[:monthly_state_benefits]
      end

      def expected_gi_student_loan
        expected_gross_income[:monthly_student_loan]
      end

      def expected_total_gross_income
        expected_gross_income[:total_gross_income]
      end

      def expected_disposable_income
        @expected[:disposable_income_summary]
      end

      def expected_disposable(key)
        expected_disposable_income[key]
      end

      def expected_capital
        @expected[:capital]
      end

      def expected_employment_income_gross
        expected_gross_income[:employment_income_gross]
      end

      def expected_employment_income_benefits_in_kind
        expected_gross_income[:employment_income_benefits_in_kind]
      end

      def expected_employment_income_tax
        expected_gross_income[:employment_income_tax]
      end

      def expected_employment_income_nic
        expected_gross_income[:employment_income_nic]
      end

      def expected_fixed_employment_allowance
        expected_gross_income[:fixed_employment_allowance]
      end
    end
  end
end
