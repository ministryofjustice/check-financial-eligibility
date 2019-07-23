class PropertiesCreationService < BaseCreationService
  attr_accessor :raw_post, :properties

  def initialize(raw_post)
    @raw_post = raw_post
    @properties = []
  end

  def call
    create
    self
  end

  private

  def create
    create_properties
  rescue CreationError => e
    self.errors = e.errors
  end

  def create_properties
    new_main_home
    new_additional_properties
  end

  def new_main_home
    new_property(payload[:properties][:main_home], true) if payload[:properties][:main_home]
  end

  def new_additional_properties
    @payload[:properties][:additional_properties]&.each do |attrs|
      new_property(attrs, false)
    end
  end

  def new_property(attrs, main_home)
    attrs[:main_home] = main_home
    @properties << assessment.properties.create!(attrs)
  end

  def assessment
    @assessment ||= Assessment.find_by(id: payload[:assessment_id]) || (raise CreationError, ['No such assessment id'])
  end

  def payload
    @payload ||= JSON.parse(@raw_post, symbolize_names: true)
  end
end
