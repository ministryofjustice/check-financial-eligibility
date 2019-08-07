class CapitalsCreationService < BaseCreationService
  attr_accessor :assessment_id, :bank_accounts_attributes, :non_liquid_capitals_attributes, :capital

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
      self.capital = {
        bank_accounts: bank_accounts,
        non_liquid_assets: non_liquid_assets
      }
    end
  rescue CreationError => e
    self.errors = e.errors
  end

  def bank_accounts
    return [] if bank_accounts_attributes.blank?

    assessment.bank_accounts.create!(bank_accounts_attributes)
  end

  def non_liquid_assets
    return [] if non_liquid_capitals_attributes.blank?

    assessment.non_liquid_assets.create!(non_liquid_capitals_attributes)
  end

  def assessment
    @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
  end
end
