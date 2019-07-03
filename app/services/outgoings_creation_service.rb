class OutgoingsCreationService < BaseCreationService
  attr_reader :params

  # Requires hash with:
  #   assessment_id: <assessment.id>
  #   outgoings: <array of outgoing attributes>
  def initialize(params)
    @params = params
  end

  def call
    self
  end

  def as_json(_options = nil)
    {
      success: success?,
      outgoings: (outgoings if success?),
      errors: errors
    }
  end

  def outgoings
    @outgoings ||= Outgoing.transaction do
      outgoing_attributes.map do |attrs|
        attrs.merge! params.slice(:assessment_id)
        Outgoing.create(attrs)
      end
    end
  end

  def errors
    @errors ||= outgoings.map { |outgoing| outgoing.errors.full_messages }.flatten.compact
  end

  def outgoing_attributes
    params[:outgoings]
  end
end
