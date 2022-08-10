class Request
	attr_accessor :headers

	def initialize
		@headers = {}
	end

	def header name, value
		@headers[name] = value
	end

	def process request
		case request[:method]
		when 'post'
			response = post request[:uri], request[:payload], @headers.merge(request[:headers])
		when 'get'
			response = get request[:uri], @headers.merge(request[:headers])
		else
			raise 'Incorrect request method provided '+request[:method]
		end
	
		result = JSON.parse(response)

		if result['success'] == false
			raise result['message']
		end

		return result
	end
end
