module Faker
  class OtherIncomeSource
    INCOMES = [
      'Help from family',
      'Student grant/loan',
      'Private pension',
      'Trust fund',
      'Rental income',
      'Bank interest',
      'Maintenance received',
      'Investment income'
    ].freeze
    class << self
      def name
        INCOMES.sample
      end
    end
  end
end
