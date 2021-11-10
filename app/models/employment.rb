class Employment < ApplicationRecord
  belongs_to :assesssment

  has_many :employment_payments, dependent: :destroy
end
