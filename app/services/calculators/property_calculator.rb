module Calculators
  class PropertyCalculator
    attr_writer :remaining_mortgage_allowance

    class << self
      def call(submission_date:, capital_summary:, level_of_representation:)
        new(submission_date:, capital_summary:, level_of_representation:).call
      end
    end

    def initialize(submission_date:, capital_summary:, level_of_representation:)
      @submission_date = submission_date
      @capital_summary = capital_summary
      @level_of_representation = level_of_representation
    end

    def call
      calculate_property
      @capital_summary.properties.sum(&:assessed_equity)
    end

    def remaining_mortgage_allowance
      @remaining_mortgage_allowance ||= Threshold.value_for(:property_maximum_mortgage_allowance, at: @submission_date)
    end

  private

    def calculate_property
      Property.transaction do
        @capital_summary.additional_properties.each do |property|
          property_assessment = Assessors::PropertyAssessor.call(property, remaining_mortgage_allowance, @level_of_representation, @submission_date)
          self.remaining_mortgage_allowance -= property_assessment.allowable_outstanding_mortgage
        end

        if @capital_summary.main_home
          Assessors::PropertyAssessor.call(@capital_summary.main_home,
                                           remaining_mortgage_allowance,
                                           @level_of_representation,
                                           @submission_date)
        end
      end
    end
  end
end
