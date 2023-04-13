module Creators
  class CashTransactionsCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(assessment:, cash_transaction_params:)
        new(assessment:, cash_transaction_params:).call
      end
    end

    def initialize(assessment:, cash_transaction_params:)
      @assessment = assessment
      @cash_transaction_params = cash_transaction_params
    end

    def call
      create_records
    end

  private

    def valid_dates
      base_date = @assessment.submission_date.beginning_of_month
      @valid_dates ||= [
        base_date - 4.months,
        base_date - 3.months,
        base_date - 2.months,
        base_date - 1.month,
      ]
    end

    def create_records
      errors = [income_attributes, outgoings_attributes].map { |categories| validate_categories(categories) }.flatten
      return Result.new(errors:).freeze unless errors.empty?

      ActiveRecord::Base.transaction do
        income_attributes.each { |category_hash| create_category(category_hash, "credit") }
        outgoings_attributes.each { |category_hash| create_category(category_hash, "debit") }
      end
      Result.new(errors: []).freeze
    end

    def validate_categories(categories)
      categories.map { |category_hash| validate_category(category_hash) }.compact
    end

    def validate_category(category_hash)
      if category_hash[:payments].size != 3
        return "There must be exactly 3 payments for category #{category_hash[:category]}"
      end

      validate_payment_dates(category: category_hash[:category], payments: category_hash[:payments])
    end

    def validate_payment_dates(category:, payments:)
      dates = payments.map { |payment| Date.parse(payment[:date]) }.sort
      return if dates == first_three_valid_dates || dates == last_three_valid_dates

      "Expecting payment dates for category #{category} to be 1st of three of the previous 3 months"
    end

    def first_three_valid_dates
      valid_dates.slice(0, 3)
    end

    def last_three_valid_dates
      valid_dates.slice(1, 3)
    end

    def create_category(category_hash, operation)
      cash_transaction_category = CashTransactionCategory.create!(gross_income_summary: @assessment.gross_income_summary,
                                                                  name: category_hash[:category],
                                                                  operation:)
      category_hash[:payments].each { |payment| create_cash_transaction(payment, cash_transaction_category) }
    end

    def create_cash_transaction(payment, cash_transaction_category)
      CashTransaction.create!(cash_transaction_category:,
                              date: Date.parse(payment[:date]),
                              amount: payment[:amount],
                              client_id: payment[:client_id])
    end

    def income_attributes
      @income_attributes ||= @cash_transaction_params[:income]
    end

    def outgoings_attributes
      @outgoings_attributes ||= @cash_transaction_params[:outgoings]
    end
  end
end
