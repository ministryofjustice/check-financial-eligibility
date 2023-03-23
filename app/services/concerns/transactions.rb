module Transactions
  def all_transaction_types
    {
      bank_transactions: transactions_by(transaction_type: :bank),
      cash_transactions: transactions_by(transaction_type: :cash),
      all_sources: transactions_by(transaction_type: :all_sources),
    }
  end

  def transactions_by(transaction_type:)
    transactions = {}

    @categories.each do |category|
      transactions[category] = @record["#{category}_#{transaction_type}"]
    end

    transactions
  end
end
