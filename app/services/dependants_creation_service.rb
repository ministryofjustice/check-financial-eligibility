class DependantsCreationService < BaseCreationService
  SCHEMA_PATH = Rails.root.join('public/schemas/dependant.json').to_s

  attr_accessor :raw_post, :dependants

  def initialize(raw_post)
    @raw_post = raw_post
  end

  def call
    create
    self
  end

  private

  def create
    create_dependants
  rescue CreationError => e
    self.errors = e.errors
  end

  def create_dependants
    self.dependants = assessment.dependants.create!(dependant_params)
  rescue ActiveRecord::RecordInvalid => e
    raise CreationError, e.record.errors.full_messages
  end

  def assessment
    @assessment ||= Assessment.find_by(id: payload[:assessment_id]) || (raise CreationError, ['No such assessment id'])
  end

  def payload
    @payload ||= JSON.parse(@raw_post, symbolize_names: true)
  end

  def dependant_params
    payload[:dependants].map do |dependant|
      dependant[:dependant_income_receipts_attributes] = dependant.delete(:income) if dependant[:income]
      dependant
    end
  end
end
