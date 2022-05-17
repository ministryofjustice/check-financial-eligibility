module Creators
  class CapitalsCreator < BaseCreator
    attr_accessor :assessment_id, :bank_accounts_attributes, :non_liquid_capitals_attributes, :capital

    delegate :capital_summary, to: :assessment

    def initialize(assessment_id:, bank_accounts_attributes: nil, non_liquid_capitals_attributes: nil)
      super()
      @assessment_id = assessment_id
      @bank_accounts_attributes = bank_accounts_attributes
      @non_liquid_capitals_attributes = non_liquid_capitals_attributes
    end

    def call
      create_records
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
      return if @bank_accounts_attributes.blank?

      @bank_accounts_attributes.each do |attrs|
        capital_summary.liquid_capital_items.create!(description: attrs[:description], value: attrs[:value])
      end
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def create_non_liquid_assets
      return if @non_liquid_capitals_attributes.blank?

      @non_liquid_capitals_attributes.each do |attrs|
        capital_summary.non_liquid_capital_items.create!(description: attrs[:description], value: attrs[:value])
      end
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end
  end
end
