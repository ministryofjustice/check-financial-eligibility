class RegularTransaction < ApplicationRecord
  belongs_to :gross_income_summary

  validates :category, :operation, :frequency, presence: true

  validates :operation, inclusion: { in: %w[credit debit],
                                     message: "%<value>s is not a valid operation" }

  validates :category, inclusion: {
    in: CFEConstants::VALID_INCOME_CATEGORIES,
    message: "is not a valid credit category: %<value>s",
  }, if: :credit?

  validates :category, inclusion: {
    in: CFEConstants::VALID_OUTGOING_CATEGORIES,
    message: "is not a valid debit category: %<value>s",
  }, if: :debit?

  validates :frequency, inclusion: {
    in: CFEConstants::VALID_FREQUENCIES.map(&:to_s),
    message: "is not a valid frequency: %<value>s",
  }

  def credit?
    operation == "credit"
  end

  def debit?
    operation == "debit"
  end
end
