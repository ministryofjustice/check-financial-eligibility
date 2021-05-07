# This class returns the correct threshold for a specified proceeding type
#
class ProceedingTypeThreshold
  WAIVABLE_THRESHOLDS = %i[capital_upper gross_income_upper disposable_income_upper].freeze

  WAIVERS = {
    DA001: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA002: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA003: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA004: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA005: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA006: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA007: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA020: {
      matter_type: 'domestic_abuse',
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    SE003: {
      matter_type: 'section8',
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    },
    SE004: {
      matter_type: 'section8',
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    },
    SE013: {
      matter_type: 'section8',
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    },
    SE014: {
      matter_type: 'section8',
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    }
  }.freeze

  def self.value_for(ccms_code, threshold, at)
    new(ccms_code, threshold, at).value
  end

  def self.matter_type(ccms_code)
    WAIVERS.fetch(ccms_code.to_sym)[:matter_type]
  end

  def initialize(ccms_code, threshold, at)
    @ccms_code = ccms_code
    @threshold = threshold
    @at = at
  end

  def value
    waivable_threshold? ? waivable_value : standard_value
  end

  def self.valid_ccms_codes
    WAIVERS.keys
  end

  private

  def waivable_threshold?
    @threshold.in?(WAIVABLE_THRESHOLDS)
  end

  def standard_value
    Threshold.value_for(@threshold, at: @at)
  end

  def waivable_value
    waived? ? waived_value : standard_value
  end

  def waived_value
    Threshold.value_for(:infinite_gross_income_upper, at: @at)
  end

  def waived?
    WAIVERS.fetch(@ccms_code).fetch(@threshold)
  end
end
