def submit_request(method, path, api_version, payload = nil)
  headers = { "HTTP_ACCEPT" => "application/json;version=#{api_version}", "HTTP_CONTENT_TYPE" => "application/json" }
  case method
  when :post
    page.driver.post(path, payload.to_json, headers)
  when :get
    page.driver.get(path, headers)
  else
    raise "Unrecognised request method provided #{method}"
  end
  result = JSON.parse(page.body)
  raise(result["errors"]&.join("\n")) unless result["success"]

  result
end

def cast_values(payload)
  payload.map { |pair| [pair[0], substitute_boolean(pair[1])] }.to_h
end

def substitute_boolean(value)
  return true if value&.casecmp("true")&.zero?
  return false if value&.casecmp("false")&.zero?

  value
end

def blank_main_home
  {
    value: 0,
    outstanding_mortgage: 0,
    percentage_owned: 0,
    shared_with_housing_assoc: false,
    subject_matter_of_dispute: false,
  }
end
