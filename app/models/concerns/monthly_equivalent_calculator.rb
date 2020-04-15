# examines all records in a given collection, to work out the equivalent value per calendar month

module MonthlyEquivalentCalculator
  # examines all records in a given collection, to work out the equivalent value per calendar month
  # params:
  # * target_field: The field on this record that is to be updated with the monthly equivalent amount
  # * collection: The collection of records to be examined for payment dates and values
  # * date_method: The method to call on each record in the collection to retrieve the payment date
  # * amount_method: The method to call on each record in the collection to retrieve the payment amount
  #
  def calculate_monthly_equivalent!(target_field:, collection:, date_method: :payment_date, amount_method: :amount)
    monthly_amount = calculate_monthly_equivalent(collection: collection, date_method: date_method, amount_method: amount_method)

    update!(target_field => monthly_amount)
    monthly_amount
  end

  def calculate_monthly_equivalent(collection:, date_method: :payment_date, amount_method: :amount)
    @converter = nil # reset the converter each time it's used
    return 0.0 if collection.empty?

    @monthly_equivalent_calculator_collection = collection
    @monthly_equivalent_calculator_date_method = date_method
    @monthly_equivalent_calculator_amount_method = amount_method
    assessment.assessment_errors.create!(record_id: id, record_type: self.class, error_message: converter.error_message) if converter.error?
    converter.monthly_amount
  end

  private

  def dates_and_amounts
    Utilities::PaymentPeriodDataExtractor.call(collection: @monthly_equivalent_calculator_collection,
                                               date_method: @monthly_equivalent_calculator_date_method,
                                               amount_method: @monthly_equivalent_calculator_amount_method)
  end

  def frequency
    @frequency ||= Utilities::PaymentPeriodAnalyser.new(dates_and_amounts).period_pattern
  end

  def converter
    @converter ||= Calculators::MonthlyIncomeConverter.new(frequency, payment_amounts)
  end

  def payment_amounts
    @monthly_equivalent_calculator_collection.map(&@monthly_equivalent_calculator_amount_method)
  end
end
