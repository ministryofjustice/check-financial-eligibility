# TODO: remove this class once version 4 is deprecated.  Work is done by Utilities::ProceedingTypeThresholdPopulator

# This class returns the correct threshold for a specified proceeding type
#
class ProceedingTypeThreshold
  def self.value_for(ccms_code, threshold, at)
    new(ccms_code, threshold, at).value
  end

  def initialize(ccms_code, threshold_type, at)
    @ccms_code = ccms_code
    @threshold_type = threshold_type
    @at = at
  end

  def value
    waived_threshold? ? waived_value : standard_value
  end

  def self.valid_ccms_codes
    CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES
  end

private

  def waived_threshold?
    LegalFrameworkAPI::QueryService.waived?(@ccms_code, @threshold_type)
  end

  def standard_value
    Threshold.value_for(@threshold_type, at: @at)
  end

  def waived_value
    Threshold.value_for(:infinite_gross_income_upper, at: @at)
  end
end
