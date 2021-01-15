module Creators
  class CashTransactionsCreator < BaseCreator
    delegate :gross_income_summary, to: :assessment

    def self.call(assessment_id:, income:, outgoings:)
      new(assessment_id, income, outgoings).call
    end

    def initialize(assessment_id, income, outgoings)
      super()
      @assessment_id = assessment_id
      @income = income
      @outgoings = outgoings
      @errors = []
    end

    def call
      create
      self
    end

    def success?
      @errors.empty?
    end

    private

    def valid_dates
      @valid_dates ||= [
        assessment.submission_date.beginning_of_month - 3.months,
        assessment.submission_date.beginning_of_month - 2.months,
        assessment.submission_date.beginning_of_month - 1.month
      ]
    end

    def pretty_dates
      valid_dates.map { |d| d.strftime('%F') }.join(', ')
    end

    def create
      [@income, @outgoings].each { |categories| validate_categories(categories) }
      return unless @errors.empty?

      ActiveRecord::Base.transaction do
        @income.each { |category_hash| create_category(category_hash, 'credit') }
        @outgoings.each { |category_hash| create_category(category_hash, 'debit') }
      rescue StandardError => error
        @errors << "#{error.class} :: #{error.message}\n#{error.backtrace.join("\n")}"
      end
    end

    def validate_categories(categories)
      categories.each { |category_hash| validate_category(category_hash) }
    end

    def validate_category(category_hash)
      if category_hash[:payments].size != 3
        @errors << "There must be exactly 3 payments for category #{category_hash[:category]}"
        return
      end
      validate_payment_dates(category_hash)
    end

    def validate_payment_dates(category_hash)
      dates = category_hash[:payments].map { |payment| Date.parse(payment[:date]) }.sort
      @errors << "Expecting payment dates for category #{category_hash[:category]} to be #{pretty_dates}" unless dates == valid_dates
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
