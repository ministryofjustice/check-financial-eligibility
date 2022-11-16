module Creators
  class IrregularIncomeCreator < BaseCreator
    attr_accessor :assessment_id

    def initialize(assessment_id:, irregular_income_params: [], gross_income_summary: nil)
      super()
      @assessment_id = assessment_id
      @irregular_income_params = irregular_income_params
      @explicit_gross_income_summary = gross_income_summary
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end
      self
    end

  private

    def irregular_income_payments
      @irregular_income_params[:payments]
    end

    def create_records
      ActiveRecord::Base.transaction do
        assessment
        create_irregular_income
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_irregular_income
      return if irregular_income_payments.empty?

      irregular_income_payments.each do |payment_params|
        gross_income_summary.irregular_income_payments.create!(
          income_type: payment_params[:income_type],
          frequency: payment_params[:frequency],
          amount: payment_params[:amount],
        )
      end
    end

    def json_validator
      @json_validator ||= JsonValidator.new("irregular_incomes", @irregular_income_params)
    end

    def gross_income_summary
      @explicit_gross_income_summary || assessment.gross_income_summary
    end
  end
end
