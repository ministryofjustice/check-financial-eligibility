class DependantIncomeReceiptSerializer < ActiveModel::Serializer
  attributes :date_of_payment, :amount

  belongs_to :dependant
end
