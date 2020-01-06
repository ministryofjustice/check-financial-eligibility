module Calculators
  class IncomeContributionCalculator
    def self.call(income)
      new(income).call
    end

    def initialize(income)
      @income = income
    end

    def call
      return 0.0 if band_name == :band_zero

      contribution
    end

    def band_details
      bands[band_name]
    end

    def band_name
      @band_name ||= determine_band_name
    end

    def determine_band_name
      thresholds = bands.map { |_k, v| v[:threshold] }
      band_value = thresholds.reverse.detect { |v| @income > v }
      bands.detect { |_k, v| v[:threshold] == band_value }.first
    end

    def bands
      Threshold.value_for(:disposable_income_contribution_bands)
    end

    def contribution
      base + ((@income - disregard) * percentage).round(2)
    end

    def base
      band_details[:base]
    end

    def disregard
      band_details[:disregard]
    end

    def percentage
      band_details[:percentage] / 100.0
    end
  end
end
