module RemarkGenerators
  class FrequencyChecker < BaseChecker
    include Exemptable

    def call
      populate_remarks if unknown_frequency? && !exempt_from_checking
    end

    private

    def unknown_frequency?
      Utilities::PaymentPeriodAnalyser.new(dates_and_amounts).period_pattern == :unknown
    end

    def dates_and_amounts
      @collection.map { |rec| [rec.payment_date, nil] }
    end

    def populate_remarks
      my_remarks = @assessment.remarks
      my_remarks.add(record_type, :unknown_frequency, @collection.map(&:client_id))
      @assessment.update!(remarks: my_remarks)
    end
  end
end
