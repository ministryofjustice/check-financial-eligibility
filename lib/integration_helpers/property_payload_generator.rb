class PropertyPayloadGenerator
  def initialize(rows)
    @rows = rows
    @payload = { properties: {} }
  end

  def run
    while @rows.any?
      generate_payload_sections
      @payload[:properties][:main_home] = @main_home_payload unless @main_home_payload.nil?
      @payload[:properties][:additional_properties] = @additional_props_payloads unless nil_or_empty?(@additional_props_payloads)
    end
    @payload.deep_symbolize_keys
  end

  private

  def generate_payload_sections
    _object, property_type, _attr, _value = @rows.first
    case property_type
    when 'main_home'
      generate_main_home_payload
    when 'additional_properties'
      generate_additional_props_payload
    else
      raise 'First row of property not main_home or additional_properties'
    end
  end

  def generate_main_home_payload
    @main_home_payload = generate_generic_payload
  end

  def generate_additional_props_payload
    @additional_props_payloads = []
    @additional_props_payloads << generate_generic_payload while @rows.any?
  end

  def generate_generic_payload
    payload = {}
    4.times do
      _object, _property_type, attr, value = @rows.shift
      payload[attr] = value
    end
    payload
  end

  def nil_or_empty?(obj)
    obj.blank?
  end
end
