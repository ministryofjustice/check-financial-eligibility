module Utilities
  class ProceedingTypeThresholdPopulator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      response = LegalFrameworkAPI::ThresholdWaivers.call(proceeding_type_details)
      store_response(response)
    end

  private

    def proceeding_type_details
      @proceeding_type_details ||= @assessment.proceeding_types.map do |pt|
        { ccms_code: pt.ccms_code, client_involvement_type: pt.client_involvement_type }
      end
    end

    def store_response(response)
      response[:proceedings].each { |pt_struct| store_thresholds(pt_struct) }
    end

    def store_thresholds(pt_struct)
      proceeding_type = @assessment.proceeding_types.find_by!(ccms_code: pt_struct[:ccms_code])
      proceeding_type.gross_income_upper_threshold = determine_threshold_for(:gross_income_upper, pt_struct[:gross_income_upper])
      proceeding_type.disposable_income_upper_threshold = determine_threshold_for(:disposable_income_upper, pt_struct[:disposable_income_upper])
      proceeding_type.capital_upper_threshold = determine_threshold_for(:capital_upper, pt_struct[:capital_upper])
      proceeding_type.save!
    end

    # returns threshold of a particular type:
    # params:
    # * threshold_type: :gross_income_upper, :disposable_income_upper or :capital_upper
    # * waived: true or false
    #
    def determine_threshold_for(threshold_type, waived)
      waived ? waived_value : standard_value(threshold_type)
    end

    def standard_value(threshold_type)
      Threshold.value_for(threshold_type, at: @assessment.submission_date)
    end

    def waived_value
      Threshold.value_for(:infinite_gross_income_upper, at: @assessment.submission_date)
    end
  end
end
