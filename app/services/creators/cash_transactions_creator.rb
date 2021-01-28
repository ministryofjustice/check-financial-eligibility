module Creators
  class CashTransactionsCreator < BaseCreator
    delegate :gross_income_summary, to: :assessment

    def initialize(assessment_id:, income:, outgoings:)
      super()
      @assessment_id = assessment_id
      @income = income
      @outgoings = outgoings
    end

    def call
      create
      self
    end

    private

    def valid_dates
      @valid_dates ||= [
        Date.current.beginning_of_month - 4.months,
        Date.current.beginning_of_month - 3.months,
        Date.current.beginning_of_month - 2.months,
        Date.current.beginning_of_month - 1.month
      ]
    end

    def create
      [@income, @outgoings].each { |categories| validate_categories(categories) }
      return unless errors.empty?

      ActiveRecord::Base.transaction do
        @income.each { |category_hash| create_category(category_hash, 'credit') }
        @outgoings.each { |category_hash| create_category(category_hash, 'debit') }
      rescue StandardError => error
        errors << "#{error.class} :: #{error.message}\n#{error.backtrace.join("\n")}"
      end
    end

    def validate_categories(categories)
      categories.each { |category_hash| validate_category(category_hash) }
    end

    def validate_category(category_hash)
      if category_hash[:payments].size != 3
        errors << "There must be exactly 3 payments for category #{category_hash[:category]}"
        return
      end
      validate_payment_dates(category_hash)
    end

    def validate_payment_dates(category_hash)
      dates = category_hash[:payments].map { |payment| Date.parse(payment[:date]) }.sort
      return if dates == first_three_valid_dates || dates == last_three_valid_dates

      errors << "Expecting payment dates for category #{category_hash[:category]} to be 1st of three of the previous 3 months"
    end

    def first_three_valid_dates
      valid_dates.slice(0, 3)
    end

    def last_three_valid_dates
      valid_dates.slice(1, 3)
    end

    def create_category(category_hash, operation)
      cash_transaction_category = CashTransactionCategory.create!(gross_income_summary: gross_income_summary,
                                                                  name: category_hash[:category],
                                                                  operation: operation)
      category_hash[:payments].each { |payment| create_cash_transaction(payment, cash_transaction_category) }
    end

    def create_cash_transaction(payment, cash_transaction_category)
      CashTransaction.create!(cash_transaction_category: cash_transaction_category,
                              date: Date.parse(payment[:date]),
                              amount: payment[:amount],
                              client_id: payment[:client_id])
    end
  end
end
