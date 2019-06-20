class CapitalsCreationService < BaseCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/capital.json').to_s

  attr_accessor :raw_post, :capital

  def initialize(raw_post)
    @raw_post = raw_post
  end

  def call
    validate_and_create
    self
  end

  private

  def validate_and_create
    validate_json
    ActiveRecord::Base.transaction do
      self.capital = {
        bank_accounts: bank_accounts,
        non_liquid_assets: non_liquid_assets
      }
    end
  rescue CreationError => e
    self.errors = e.errors
  end

  def validate_json
    raise CreationError, json_validator.errors unless json_validator.valid?
  end

  def json_validator
    @json_validator ||= JsonSchemaValidator.new(raw_post, SCHEMA_PATH)
  end

  def bank_accounts
    assessment.bank_accounts.create!(payload[:liquid_capital][:bank_accounts])
  end

  def non_liquid_assets
    assessment.non_liquid_assets.create!(payload[:non_liquid_capital])
  end

  def assessment
    @assessment ||= Assessment.find_by(id: payload[:assessment_id]) || (raise CreationError, ['No such assessment id'])
  end

  def payload
    @payload ||= JSON.parse(raw_post, symbolize_names: true)
  end
end
