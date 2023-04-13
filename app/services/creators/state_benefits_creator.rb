module Creators
  class StateBenefitsCreator
    Result = Struct.new(:errors, keyword_init: true) do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(gross_income_summary:, state_benefits_params:)
        ActiveRecord::Base.transaction do
          create_state_benefits(gross_income_summary:, state_benefits_params:)
          Result.new(errors: []).freeze
        rescue ActiveRecord::RecordInvalid => e
          Result.new(errors: e.record.errors.full_messages).freeze
        end
      end

    private

      def create_state_benefits(gross_income_summary:, state_benefits_params:)
        state_benefits_params[:state_benefits].each do |state_benefit_attributes|
          create_state_benefit(gross_income_summary:, state_benefit_attributes:)
        end
      end

      def create_state_benefit(gross_income_summary:, state_benefit_attributes:)
        state_benefit = StateBenefit.generate!(gross_income_summary, state_benefit_attributes[:name])
        state_benefit_attributes[:payments].each do |payment|
          state_benefit.state_benefit_payments.create!(
            payment_date: payment[:date],
            amount: payment[:amount],
            client_id: payment[:client_id],
            flags: generate_flags(payment),
          )
        end
      end

      def generate_flags(hash)
        return false if hash[:flags].blank?

        hash[:flags].map { |k, v| k if v.eql?(true) }.compact
      end
    end
  end
end
