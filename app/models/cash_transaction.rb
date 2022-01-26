class CashTransaction < ApplicationRecord
  belongs_to :cash_transaction_category

  scope :by_operation_and_category, ->(assessment, operation, category_name) do
    joins(:cash_transaction_category)
      .where(cash_transaction_category: { name: category_name, operation:, gross_income_summary_id: assessment.gross_income_summary.id })
      .order(:date)
  end
end
