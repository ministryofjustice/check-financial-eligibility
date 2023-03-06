module Utilities
  class ProceedingTypeThresholdPopulator
    def self.call(assessment)
      new(assessment).call
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      retrieve_waiver_data if waivers_may_apply?
      populate_thresholds
    end

  private

    def retrieve_waiver_data
      service = Rails.env.production? ? LegalFrameworkAPI::ThresholdWaivers : LegalFrameworkAPI::MockThresholdWaivers
      @waiver_data = service.call(proceeding_type_details).fetch(:proceedings)
    end

    def proceeding_type_details
      @assessment.proceeding_types.order(:ccms_code).map do |pt|
        { ccms_code: pt.ccms_code, client_involvement_type: pt.client_involvement_type }
      end
    end

    def populate_thresholds
      @assessment.proceeding_types.each do |proceeding_type|
        waivers = @waiver_data&.find { _1[:ccms_code] == proceeding_type.ccms_code } || {}
        store_thresholds(proceeding_type, waivers)
      end
    end

    def store_thresholds(proceeding_type, waivers)
      proceeding_type.update(
        gross_income_upper_threshold: determine_threshold_for(:gross_income_upper, waivers[:gross_income_upper]),
        disposable_income_upper_threshold: determine_threshold_for(:disposable_income_upper, waivers[:disposable_income_upper]),
        capital_upper_threshold: determine_threshold_for(:capital_upper, waivers[:capital_upper]),
      )
    end

    # returns threshold of a particular type:
    # params:
    # * threshold_type: :gross_income_upper, :disposable_income_upper or :capital_upper
    # * waived: true, false or nil (where nil is equivalent to false)
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

    def waivers_may_apply?
      @assessment.level_of_help == "certificated" && @assessment.proceeding_types.none? do |type|
        type.ccms_code.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES.map(&:to_s))
      end
    end
  end
end
