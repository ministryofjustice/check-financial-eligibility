class CashTransaction < ApplicationRecord
  belongs_to :cash_transaction_category

  scope :by_category_id, ->(id) do
    where(cash_transaction_category_id: id)
  end
end
