class VehicleSerializer < ActiveModel::Serializer
  attributes :id,
             :value,
             :loan_amount_outstanding,
             :date_of_purchase,
             :in_regular_use

end
