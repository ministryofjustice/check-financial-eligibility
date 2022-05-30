module Creators
  class CapitalsCreator < BaseCreator
    attr_accessor :assessment_id, :capital, :capital_params

    delegate :capital_summary, to: :assessment

    def initialize(assessment_id:, capital_params:)
      super()
      @assessment_id = assessment_id
      @capital_params = capital_params
    end

    def call
      if json_validator.valid?
        create_records
      else
        self.errors = json_validator.errors
      end
      self
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
        capital_summary.liquid_capital_items.create!(description: attrs["description"], value: attrs["value"])
      end
    end

    def create_non_liquid_assets
      return if non_liquid_capitals_attributes.nil?

      non_liquid_capitals_attributes.each do |attrs|
        capital_summary.non_liquid_capital_items.create!(description: attrs["description"], value: attrs["value"])
      end
    end

    def json_validator
      @json_validator ||= JsonValidator.new("capital", capital_params)
    end

    def bank_accounts_attributes
      parsed_params["bank_accounts"]
    end

    def non_liquid_capitals_attributes
      parsed_params["non_liquid_capital"]
    end

    def parsed_params
      JSON.parse(capital_params)
    end
  end
end
