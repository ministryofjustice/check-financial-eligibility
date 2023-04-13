module Creators
  class PartnerFinancialsCreator
    Result = Struct.new(:errors, keyword_init: true) do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(assessment:, partner_financials_params:)
        new(assessment:, partner_financials_params:).call
      end
    end

    def initialize(assessment:, partner_financials_params:)
      @assessment = assessment
      @partner_financials_params = partner_financials_params
    end

    def call
      Assessment.transaction do
        create_records
      end
    end

  private

    attr_reader :assessment

    def create_records
      errors = []
      errors.concat(create_partner.errors)
      errors.concat(create_summaries.errors)
      errors.concat(create_irregular_income.errors)
      errors.concat(create_employments.errors)
      errors.concat(create_regular_transactions.errors)
      errors.concat(create_state_benefits.errors)
      errors.concat(create_additional_properties.errors)
      errors.concat(create_capitals.errors)
      errors.concat(create_vehicles.errors)
      errors.concat(create_dependants.errors)
      errors.concat(create_outgoings.errors)
      Result.new(errors:).freeze
    rescue ActiveRecord::RecordInvalid => e
      Result.new(errors: e.record.errors.full_messages).freeze
    end

    def create_partner
      if assessment.partner.present?
        Result.new(errors: ["There is already a partner for this assesssment"]).freeze
      else
        assessment.create_partner!(partner_attributes.slice(:date_of_birth, :employed))
        Result.new(errors: []).freeze
      end
    end

    def create_summaries
      assessment.create_partner_capital_summary!
      assessment.create_partner_gross_income_summary!
      assessment.create_partner_disposable_income_summary!
      Result.new(errors: []).freeze
    end

    def create_irregular_income
      return Result.new(errors: []) if irregular_income_params.blank?

      IrregularIncomeCreator.call(
        irregular_income_params: { payments: irregular_income_params },
        gross_income_summary: assessment.partner_gross_income_summary,
      )
    end

    def create_regular_transactions
      return Result.new(errors: []).freeze if regular_transaction_params.blank?

      RegularTransactionsCreator.call(
        regular_transaction_params: { regular_transactions: regular_transaction_params },
        gross_income_summary: assessment.partner_gross_income_summary,
      )
    end

    def create_employments
      return Result.new(errors: []).freeze if employment_params.blank?

      employments_params = { employment_income: employment_params }
      EmploymentsCreator.call(
        employments_params:,
        employment_collection: assessment.partner_employments,
      )
    end

    def create_state_benefits
      return Result.new(errors: []).freeze if state_benefit_params.blank?

      StateBenefitsCreator.call(
        state_benefits_params: { state_benefits: state_benefit_params },
        gross_income_summary: assessment.partner_gross_income_summary,
      )
    end

    def create_additional_properties
      return Result.new(errors: []).freeze if additional_property_params.blank?

      PartnerPropertiesCreator.call(
        capital_summary: assessment.partner_capital_summary,
        properties_params: additional_property_params,
      )
    end

    def create_capitals
      return Result.new(errors: []).freeze if capital_params.blank?

      CapitalsCreator.call(
        capital_params:,
        capital_summary: assessment.partner_capital_summary,
      )
    end

    def create_vehicles
      return Result.new(errors: []).freeze if vehicle_params.blank?

      VehicleCreator.call(
        vehicles_params: { vehicles: vehicle_params },
        capital_summary: assessment.partner_capital_summary,
      )
    end

    def create_outgoings
      return Result.new(errors: []).freeze if outgoings_params.blank?

      OutgoingsCreator.call(
        disposable_income_summary: assessment.partner_disposable_income_summary,
        outgoings_params: { outgoings: outgoings_params },
      )
    end

    def create_dependants
      return Result.new(errors: []).freeze if dependant_params.blank?

      DependantsCreator.call(
        dependants: @assessment.partner_dependants,
        dependants_params: { dependants: dependant_params },
      )
    end

    def partner_attributes
      @partner_attributes ||= @partner_financials_params[:partner]
    end

    def irregular_income_params
      @irregular_income_params ||= @partner_financials_params[:irregular_incomes]
    end

    def regular_transaction_params
      @regular_transaction_params ||= @partner_financials_params[:regular_transactions]
    end

    def employment_params
      @employment_params ||= @partner_financials_params[:employments]
    end

    def state_benefit_params
      @state_benefit_params ||= @partner_financials_params[:state_benefits]
    end

    def additional_property_params
      @additional_property_params ||= @partner_financials_params[:additional_properties]
    end

    def capital_params
      @capital_params ||= @partner_financials_params[:capitals]
    end

    def vehicle_params
      @vehicle_params ||= @partner_financials_params[:vehicles]
    end

    def dependant_params
      @dependant_params ||= @partner_financials_params[:dependants]
    end

    def outgoings_params
      @partner_financials_params[:outgoings]
    end
  end
end
