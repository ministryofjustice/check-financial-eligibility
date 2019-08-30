class CapitalsCreationService < BaseCreationService
  attr_accessor :assessment_id, :bank_accounts_attributes, :non_liquid_capitals_attributes, :capital

  delegate :capital_summary, to: :assessment

  def initialize(assessment_id:, bank_accounts_attributes: nil, non_liquid_capitals_attributes: nil)
    @assessment_id = assessment_id
    @bank_accounts_attributes = bank_accounts_attributes
    @non_liquid_capitals_attributes = non_liquid_capitals_attributes
  end

  def call
    create
    self
  end

  private

  def create
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
  end

  def create_non_liquid_assets
    return if @non_liquid_capitals_attributes.blank?

    @non_liquid_capitals_attributes.each do |attrs|
      capital_summary.non_liquid_capital_items.create!(description: attrs[:description], value: attrs[:value])
    end
  end

  def assessment
    @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
  end
end
