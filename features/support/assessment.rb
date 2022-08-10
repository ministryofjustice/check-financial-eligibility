class Assessment
	attr_accessor :version
	attr_accessor :id
    attr_accessor :response
	attr_reader :uris
	attr_writer :headers

	def initialize
      @uris = Routes.new.collection

      @headers = {}
    end

    def add_header name, value
    	@headers[name] = value
    end

    def api_version version
        @version = version
        add_header 'Accept', "application/json;version=#{version}"
    end

    def get_request name, payload = {}, params = {}
        unless @uris.key?(:"#{name}")
            raise "Unable to find request details for '#{name}'"
        end

        request = @uris[:"#{name}"]

        if request.nil?
        	raise "Expected to find a request details for #{name}, but nothing found. Please ensure method and uri are defined correctly in routes."
        end

        params.each_pair do | index, param | request[:uri] = request[:uri].gsub("{#{index}}", param) end

        if not payload.empty?
        	request = request.merge({:payload => payload})
        end

        request.merge({:headers => @headers})
    end

    def cleanse payload
    	payload = payload.to_json.gsub(/"(true)"/i, 'true').gsub(/"(false)"/i, 'false')

		JSON.parse(payload)
    end
end
