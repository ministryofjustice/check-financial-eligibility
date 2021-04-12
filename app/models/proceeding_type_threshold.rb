# This class returns the correct threshold for a specified proceeding type
#
class ProceedingTypeThreshold
  WAIVABLE_THRESHOLDS = %i[capital_upper gross_income_upper disposable_income_upper].freeze

  WAIVERS = {
    DA001: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA002: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA003: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA004: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA005: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA006: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA007: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    DA020: {
      capital_upper: true,
      gross_income_upper: true,
      disposable_income_upper: true
    },
    SE003: {
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    },
    SE004: {
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    },
    SE013: {
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    },
    SE014: {
      capital_upper: false,
      gross_income_upper: false,
      disposable_income_upper: false
    }
  }.freeze

  def self.value_for(ccms_code, threshold, at)
    new(ccms_code, threshold, at).value
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
