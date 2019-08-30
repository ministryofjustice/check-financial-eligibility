class PropertiesCreationService < BaseCreationService
  attr_accessor :assessment_id, :main_home_attributes, :additional_properties_attributes, :properties

  delegate :capital_summary, to: :assessment

  def initialize(assessment_id:, main_home_attributes: nil, additional_properties_attributes: [])
    @assessment_id = assessment_id
    @main_home_attributes = main_home_attributes
    @additional_properties_attributes = additional_properties_attributes
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
    new_property(main_home_attributes, true) if main_home_attributes
  end

  def new_additional_properties
    additional_properties_attributes&.each do |attrs|
      new_property(attrs, false)
    end
  end

  def new_property(attrs, main_home)
    attrs[:main_home] = main_home
    @properties << capital_summary.properties.create!(attrs)
  end

  def assessment
    @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
  end

  # def capital_summary
  #   assessment.capital_summary
  # end
end
