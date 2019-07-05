module RequestHelpers
  def self.included(base)
    base.include(JsonHelpers)
  end

  module JsonHelpers
    def parsed_response
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
