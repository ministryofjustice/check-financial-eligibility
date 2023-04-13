module Creators
  class IrregularIncomeCreator
    class << self
      CreationResult = Data.define(:success?, :errors)

      def call(irregular_income_params:, gross_income_summary:)
        irregular_income_params[:payments].each do |payment_params|
          gross_income_summary.irregular_income_payments.create!(
            income_type: payment_params[:income_type],
            frequency: payment_params[:frequency],
            amount: payment_params[:amount],
          )
        end

        CreationResult.new(success?: true, errors: [])
      end
    end
  end
end
