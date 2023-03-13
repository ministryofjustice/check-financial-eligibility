module Creators
  class IrregularIncomeCreator
    class << self
      CreationResult = Struct.new :errors, keyword_init: true do
        def success?
          errors.empty?
        end
      end

      def call(irregular_income_params:, gross_income_summary:)
        json_validator = JsonValidator.new("irregular_incomes", irregular_income_params)
        if json_validator.valid?
          create_records irregular_income_params[:payments], gross_income_summary
          CreationResult.new(errors: []).freeze
        else
          CreationResult.new(errors: json_validator.errors).freeze
        end
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
