module Creators
  class IrregularIncomeCreator
    class << self
      CreationResult = Data.define(:success?)

      def call(irregular_income_params:, gross_income_summary:)
        create_records irregular_income_params[:payments], gross_income_summary
        CreationResult.new(success?: true)
      end

      def create_records(irregular_income_payments, gross_income_summary)
        irregular_income_payments.each do |payment_params|
          gross_income_summary.irregular_income_payments.create!(
            income_type: payment_params[:income_type],
            frequency: payment_params[:frequency],
            amount: payment_params[:amount],
          )
        end
      end
    end
  end
end
