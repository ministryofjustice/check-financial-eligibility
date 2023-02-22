module Creators
  class RegularTransactionsCreator < BaseCreator
    attr_accessor :assessment_id

    def initialize(assessment_id:, regular_transaction_params: [], gross_income_summary: nil)
      super()
      @assessment_id = assessment_id
      @regular_transaction_params = regular_transaction_params
      @explicit_gross_income_summary = gross_income_summary
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end

      self
    end

  private

    def create_records
      ActiveRecord::Base.transaction do
        assessment
        create_regular_transaction
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_regular_transaction
      return if regular_transactions.empty?

      regular_transactions.each do |regular_transaction|
        gross_income_summary.regular_transactions.create!(
          category: regular_transaction[:category],
          operation: regular_transaction[:operation],
          amount: regular_transaction[:amount],
          frequency: regular_transaction[:frequency],
        )
      end
    end

    def regular_transactions
      @regular_transactions ||= @regular_transaction_params.fetch(:regular_transactions)
    end

    def json_validator
      @json_validator ||= JsonValidator.new("regular_transactions", @regular_transaction_params)
    end

    def gross_income_summary
      @explicit_gross_income_summary || assessment.gross_income_summary
    end
  end
end
