class CashTransactionCategory < ApplicationRecord
  belongs_to :gross_income_summary
  has_many :cash_transactions, dependent: :destroy

  validates :operation, inclusion: { in: %w[credit debit],
                                     message: '%<value>s is not a valid operation' }

  validates :name, presence: true

  validates :name, inclusion: {
    in: CFEConstants::VALID_INCOME_CATEGORIES,
    message: 'is not a valid credit category: %<value>s'
  }, if: :credit?

  validates :name, inclusion: {
    in: CFEConstants::VALID_OUTGOING_CATEGORIES,
    message: 'is not a valid debit category: %<value>s'
  }, if: :debit?

  scope :credits_by_category, ->(category) do
    record = find_by(operation: :credit, name: category)
    transactions(record&.id)
  end

  scope :debits_by_category, ->(category) do
    record = find_by(operation: :debit, name: category)
    transactions(record&.id)
  end

  scope :transactions, ->(id) { CashTransaction.by_category_id(id) }

  def credit?
    operation == 'credit'
  end

  def debit?
    operation == 'debit'
  end
end
