# class for extracting data to pass into the PaymentPeriodAnalyser from a collection of records
module Utilities
  class PaymentPeriodDataExtractor
    def self.call(collection:, date_method:, amount_method:)
      new(collection, date_method, amount_method).call
    end

    def initialize(collection, date_method, amount_method)
      @collection = collection
      @date_method = date_method
      @amount_method = amount_method
    end

    def call
      @collection.map do |record|
        [record.__send__(@date_method), record.__send__(@amount_method)]
      end
    end
  end
end
