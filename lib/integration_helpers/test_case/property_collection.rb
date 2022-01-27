module TestCase
  class PropertyCollection
    def initialize(rows)
      @properties = Hash.new { |hash, key| hash[key] = [] }
      populate_properties(rows)
    end

    def url_method
      :assessment_properties_path
    end

    def payload
      return if empty?

      {
        properties: {
          main_home: main_home.payload,
          additional_properties: additional_properties.map(&:payload)
        }
      }
    end

    def empty?
      main_home.payload.nil? && additional_properties.empty?
    end

  private

    def main_home
      @properties['main_home'].first
    end

    def additional_properties
      @properties['additional_properties']
    end

    def populate_properties(rows)
      property_rows = extract_property_rows(rows)
      property_type = property_rows.first[1]

      while property_rows.any?
        property_data = property_rows.shift(4)
        property_type = property_data.first[1] if property_data.first[1].present?
        @properties[property_type] << Property.new(property_type, property_data)
      end
    end

    def extract_property_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != 'properties' }
      rows.shift(row_index)
    end
  end
end
