module Creators
  class RegularTransactionsCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(regular_transaction_params:, gross_income_summary:)
        ActiveRecord::Base.transaction do
          create_regular_transaction(regular_transactions: regular_transaction_params.fetch(:regular_transactions, []),
                                     gross_income_summary:)
        end
        Result.new(errors: []).freeze
      rescue ActiveRecord::RecordInvalid => e
        Result.new(errors: e.record.errors.full_messages).freeze
      end

      private

      def create_regular_transaction(regular_transactions:, gross_income_summary:)
        regular_transactions.each do |regular_transaction|
          gross_income_summary.regular_transactions.create!(
            category: regular_transaction[:category],
            operation: regular_transaction[:operation],
            amount: regular_transaction[:amount],
            frequency: regular_transaction[:frequency],
          )
        end
      end
      end
  end
end
