module Calculators
  class TaxNiRefundCalculator
    def self.call(employment)
      new(employment).call

    end

    def initialize(employment)
      @employment = employment
    end

    def call


      @employment.employment_payments.each do |payment|
        attrs = {}

        attrs[:tax] = 0 if payment.tax >= 0
        attrs[:national_insurance] = 0 if payment.national_insurance >= 0

        payment.update!(attrs) unless attrs.empty?
      end
    end
  end
end
