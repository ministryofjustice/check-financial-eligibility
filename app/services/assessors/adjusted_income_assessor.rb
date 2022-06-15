module Assessors
    class AdjustedIncomeAssessor < BaseWorkflowService
      delegate :adjusted_income, :crime_eligibilities, :total_gross_income, to: :gross_income_summary
      delegate :dependants, to: :assessment
  
      def call
        ActiveRecord::Base.transaction do
          update_eligibility_records
          # gross_income_summary.update!(income_contribution:)
        end
      end
  
    private
  
      def update_eligibility_records
        crime_eligibilities.each do |elig|
          elig.update!(assessment_result: assessment_result(elig))
        end
      end
  
      def assessment_result(elig)
        if adjusted_income <= elig.lower_threshold
         :eligible
        elsif adjusted_income <= elig.upper_threshold
          :full_means_test_required
        else
          :ineligible
        end
      end

      def adjusted_income
        if dependants.empty?
          total_gross_income
        else
          total_gross_income / collated_weightings 
        end
      end

      def collated_weightings
        dependants_ages = dependants.map(&:age_at_submission).map{ |age| age + 1 }
        weightings = dependants_ages.map(&:weightings).reduce(:+)

        p dependants
        weightings
      end

      def weightings(age_at_submission)
        case age_at_submission
        when 1
            0.15
        when 2, 3, 4
            0.3
        when 5, 6, 7
            0.34
        when 8, 9, 10
            0.38
        when 11, 12
            0.41
        when 13, 14, 15
            0.44
        when 16, 17, 18
            0.59
        else
            0
        end
      end
    end
  end
  