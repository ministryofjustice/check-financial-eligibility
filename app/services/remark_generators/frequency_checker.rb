module RemarkGenerators
  class FrequencyChecker < BaseChecker
    include Exemptable

    def self.call(assessment, collection, date_field = "payment_date")
      new(assessment, collection).call(date_field)
    end

    def call(date_field = "payment_date")
      @date_field = date_field
      populate_remarks if unknown_frequency? && !exempt_from_checking
    end

  private

    def unknown_frequency?
      Utilities::PaymentPeriodAnalyser.new(dates).period_pattern == :unknown
    end

    def dates_and_amounts
      @collection.map { |rec| [rec.send(@date_field), nil] }
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
