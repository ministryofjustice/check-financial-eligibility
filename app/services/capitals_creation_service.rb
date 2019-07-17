class CapitalsCreationService < BaseCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/capital.json').to_s

  attr_accessor :raw_post, :capital

  def initialize(raw_post)
    @raw_post = raw_post
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
    return [] if payload[:liquid_capital].nil?

    assessment.bank_accounts.create!(payload[:liquid_capital][:bank_accounts])
  end

  def non_liquid_assets
    return [] if payload[:non_liquid_capital].nil?

    assessment.non_liquid_assets.create!(payload[:non_liquid_capital])
  end

  def assessment
    @assessment ||= Assessment.find_by(id: payload[:assessment_id]) || (raise CreationError, ['No such assessment id'])
  end

  def payload
    @payload ||= JSON.parse(raw_post, symbolize_names: true)
  end
end
