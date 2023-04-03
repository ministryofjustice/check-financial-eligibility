module Creators
  class PartnerFinancialsCreator < BaseCreator
    attr_accessor :assessment_id

    def initialize(assessment_id:, partner_financials_params:)
      super()
      @assessment_id = assessment_id
      @partner_financials_params = partner_financials_params
    end

    def call
      Assessment.transaction { create_records }
      self
    end

  private

    def create_records
      create_partner
      create_summaries
      create_irregular_income
      create_employments
      create_regular_transactions
      create_state_benefits
      create_additional_properties
      create_capitals
      create_vehicles
      create_dependants
      create_outgoings
    rescue CreationError => e
      self.errors = e.errors
    end

    def create_partner
      raise(CreationError, ["There is already a partner for this assesssment"]) if assessment.partner.present?

      assessment.create_partner!(partner_attributes.slice(:date_of_birth, :employed))
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def create_summaries
      assessment.create_partner_capital_summary!
      assessment.create_partner_gross_income_summary!
      assessment.create_partner_disposable_income_summary!
    end

    def create_irregular_income
      return if irregular_income_params.blank?

      IrregularIncomeCreator.call(
        irregular_income_params: { payments: irregular_income_params },
        gross_income_summary: assessment.partner_gross_income_summary,
      )
    end

    def create_regular_transactions
      return if regular_transaction_params.blank?

      creator = RegularTransactionsCreator.call(
        assessment_id: @assessment_id,
        regular_transaction_params: { regular_transactions: regular_transaction_params },
        gross_income_summary: assessment.partner_gross_income_summary,
      )

      errors.concat(creator.errors)
    end

    def create_employments
      return if employment_params.blank?

      employments_params = { employment_income: employment_params }
      creator = EmploymentsCreator.call(
        employments_params:,
        employment_collection: assessment.partner_employments,
      )

      errors.concat(creator.errors)
    end

    def create_state_benefits
      return if state_benefit_params.blank?

      creator = StateBenefitsCreator.call(
        assessment_id: @assessment_id,
        state_benefits_params: { state_benefits: state_benefit_params },
        gross_income_summary: assessment.partner_gross_income_summary,
      )

      errors.concat(creator.errors)
    end

    def create_additional_properties
      return if additional_property_params.blank?

      creator = PartnerPropertiesCreator.call(
        assessment_id: @assessment_id,
        properties_params: additional_property_params,
      )

      errors.concat(creator.errors)
    end

    def create_capitals
      return if capital_params.blank?

      CapitalsCreator.call(
        capital_params:,
        capital_summary: assessment.partner_capital_summary,
      )
    end

    def create_vehicles
      return if vehicle_params.blank?

      creator = VehicleCreator.call(
        assessment_id: @assessment_id,
        vehicles_params: { vehicles: vehicle_params },
        capital_summary: assessment.partner_capital_summary,
      )

      errors.concat(creator.errors)
    end

    def create_outgoings
      return if outgoings_params.blank?

      creator = OutgoingsCreator.call(
        disposable_income_summary: assessment.partner_disposable_income_summary,
        outgoings_params: { outgoings: outgoings_params },
      )

      errors.concat(creator.errors)
    end

    def create_dependants
      return if dependant_params.blank?

      creator = DependantsCreator.call(
        assessment_id: @assessment_id,
        dependants_params: { dependants: dependant_params },
        relationship: :partner_dependants,
      )

      errors.concat(creator.errors)
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
