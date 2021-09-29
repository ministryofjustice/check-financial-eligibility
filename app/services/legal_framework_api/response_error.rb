module LegalFrameworkAPI
  class ResponseError < StandardError
    def initialize(raw_response)
      super formatted_message(raw_response)
    end

    private

    def formatted_message(raw_response)
      <<~END_OF_MESSAGE.chomp
        Invalid response from Legal Framework API
        Status: #{raw_response.status}
        Response: #{raw_response.body}
      END_OF_MESSAGE
    end
  end
end
