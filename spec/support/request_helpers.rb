module RequestHelpers
  def self.included(base)
    base.include(JsonHelpers)
  end

  module JsonHelpers
    def parsed_response
      json = response.body.gsub('"-0.0"', '"0.0"')
      JSON.parse(json, symbolize_names: true)
    end
  end
end
