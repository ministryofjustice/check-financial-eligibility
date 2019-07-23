class DependantSerializer < ActiveModel::Serializer
  attributes :date_of_birth, :in_full_time_education

  has_many :dependant_income_receipts, serializer: DependantIncomeReceiptSerializer
end
