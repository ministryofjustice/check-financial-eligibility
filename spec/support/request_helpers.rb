module RequestHelpers
  def self.included(base)
    base.include(JsonHelpers)
  end

  module JsonHelpers
    def json
      JSON.parse(response.body)
    end
  end
end
