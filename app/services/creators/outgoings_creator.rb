module Creators
  class OutgoingsCreator < BaseCreator
    OUTGOING_KLASSES = {
      child_care: Outgoings::Childcare,
      childcare: Outgoings::Childcare, # retained for compatibility with earlier versions of integration test spreadsheet
      rent_or_mortgage: Outgoings::HousingCost,
      housing_costs: Outgoings::HousingCost, # retained for compatibility with earlier versions of integration test spreadsheet
      maintenance_out: Outgoings::Maintenance,
      maintenance: Outgoings::Maintenance, # retained for compatibility with earlier versions of integration test spreadsheet
      legal_aid: Outgoings::LegalAid
    }.freeze

    VALID_OUTGOING_TYPES = OUTGOING_KLASSES.keys.map(&:to_s).freeze

    def initialize(assessment_id:, outgoings:)
      @assessment_id = assessment_id
      @outgoings = outgoings
    end

    def call
      ActiveRecord::Base.transaction do
        @outgoings.each { |outgoing| create_outgoing_collection(outgoing) }
      end
      self
    end

    private

    def create_outgoing_collection(outgoing)
      klass = OUTGOING_KLASSES[outgoing[:name].to_sym]
      payments = outgoing[:payments]
      payments.each do |payment_params|
        klass.create! payment_params.merge(disposable_income_summary: disposable_income_summary)
      end
    end

    def disposable_income_summary
      @disposable_income_summary ||= find_or_create_disposable_income_summary
    end

    def find_or_create_disposable_income_summary
      assessment.disposable_income_summary || assessment.create_disposable_income_summary
    end
  end
end
