module RemarkGenerators
  class FrequencyChecker < BaseChecker
    include Exemptable

    def call
      populate_remarks if unknown_frequency? && !exempt_from_checking
    end

    private

    def unknown_frequency?
      Utilities::NewPaymentPeriodAnalyser.new(dates).period_pattern == :unknown
    end

    def dates_and_amounts
      @collection.map { |rec| [rec.payment_date, nil] }
    end

    def dates
      dates_and_amounts.map(&:first)
    end

    def populate_remarks
      my_remarks = @assessment.remarks
      my_remarks.add(record_type, :unknown_frequency, @collection.map(&:client_id))
      @assessment.update!(remarks: my_remarks)
    end
  end
end
