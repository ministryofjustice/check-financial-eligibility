module Creators
  class CapitalsCreator < BaseCreator
    def initialize(assessment_id:, capital_params:, capital_summary: nil)
      super()
      @assessment_id = assessment_id
      @capital_params = capital_params
      @explicit_capital_summary = capital_summary
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end
      self
    end

    def capital_summary
      @explicit_capital_summary || assessment.capital_summary
    end

  private

    def create_records
      ActiveRecord::Base.transaction do
        assessment
        create_liquid_assets
        create_non_liquid_assets
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_liquid_assets
      return if bank_accounts_attributes.nil?

      bank_accounts_attributes.each do |attrs|
        capital_summary.liquid_capital_items.create!(attrs.slice(:value, :description, :subject_matter_of_dispute))
      end
    end

    def create_non_liquid_assets
      return if non_liquid_capital_attributes.nil?

      non_liquid_capital_attributes.each do |attrs|
        capital_summary.non_liquid_capital_items.create!(attrs.slice(:value, :description, :subject_matter_of_dispute))
      end
    end

    def json_validator
      @json_validator ||= JsonValidator.new("capital", @capital_params)
    end

    def bank_accounts_attributes
      @bank_accounts_attributes ||= JSON.parse(@capital_params, symbolize_names: true)[:bank_accounts]
    end

    def non_liquid_capital_attributes
      @non_liquid_capital_attributes ||= JSON.parse(@capital_params, symbolize_names: true)[:non_liquid_capital]
    end
  end
end
