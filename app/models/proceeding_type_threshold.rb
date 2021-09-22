# This class returns the correct threshold for a specified proceeding type
#
class ProceedingTypeThreshold
  VALID_CCMS_CODES = %i[DA001 DA002 DA003 DA004 DA005 DA006 DA007 DA020 SE003 SE004 SE013 SE014].freeze

  def self.value_for(ccms_code, threshold, at)
    new(ccms_code, threshold, at).value
  end

  def self.matter_type(ccms_code)
    LegalFrameworkAPI::QueryService.matter_type(ccms_code.to_sym)
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
    VALID_CCMS_CODES
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
