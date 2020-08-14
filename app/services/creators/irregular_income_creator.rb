module Creators
  class IrregularIncomeCreator < BaseCreator
    attr_accessor :assessment_id

    delegate :gross_income_summary, to: :assessment

    attr_reader :irregular_income_payments

    def initialize(assessment_id:, irregular_income: [])
      super()
      @assessment_id = assessment_id
      @irregular_income_payments = irregular_income[:payments]
    end

    def call
      create
      self
    end

    private

    def create
      ActiveRecord::Base.transaction do
        assessment
        create_irregular_income
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_irregular_income
      return if @irregular_income_payments.empty?

      @irregular_income_payments.each do |payment_params|
        gross_income_summary.irregular_income_payments.create!(
          income_type: payment_params[:income_type],
          frequency: payment_params[:frequency],
          amount: payment_params[:amount]
        )
      end
    end
  end
end
