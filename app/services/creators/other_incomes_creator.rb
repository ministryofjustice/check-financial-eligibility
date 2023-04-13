module Creators
  class OtherIncomesCreator
    Result = Data.define(:success?)

    class << self
      def call(assessment:, other_incomes_params:)
        ActiveRecord::Base.transaction do
          create_other_income(assessment:, other_incomes_params:)
        end
        Result.new(success?: true)
      end

    private

      def create_other_income(assessment:, other_incomes_params:)
        other_incomes(other_incomes_params).each do |other_income_source_params|
          create_other_income_source(assessment:, other_income_source_params:)
        end
      end

      def create_other_income_source(assessment:, other_income_source_params:)
        other_income_source = assessment.gross_income_summary.other_income_sources.create!(name: normalize(other_income_source_params[:source]))
        other_income_source_params[:payments].each do |payment_params|
          other_income_source.other_income_payments.create!(
            payment_date: payment_params[:date],
            amount: payment_params[:amount],
            client_id: payment_params[:client_id],
          )
        end
      end

      def normalize(name)
        name.underscore.tr(" ", "_")
      end

      def other_incomes(other_incomes_params)
        other_incomes_params.fetch(:other_incomes, nil)
      end
    end
  end
end
