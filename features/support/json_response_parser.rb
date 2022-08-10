def get_mapping version, attribute
	unless mapping.key?("v#{version}")
		raise "Provided version '#{version}' does not have any mapping defined."
	end

	api_mapping = mapping["v#{version}"]

	unless api_mapping.key?(attribute)
		raise "Provided attribute '#{attribute}' was not found in mapping for version '#{version}'. Available attributes are: #{api_mapping.map{|k,v| "#{k} => #{v}"}}"
	end

	api_mapping[attribute]
end

# Fetch the json values from within the response based on the mapping defined for the section
def get_value_from_response response, version, attribute
	sectionPath = get_mapping version, attribute

	# Drill down into the JSON and extract the value out. Works with hash and array structures.
	value = ''
	sectionPath.split('.').each do | bit |
		if response.is_a?(Array)
			bit = bit.to_i
		end

		if response[bit] == nil
			raise "Expected to have key '#{bit}' in '#{response}' using attribute '#{attribute}' with path '#{sectionPath}'"
		end
		value = response = response[bit]
	end

	value
end
