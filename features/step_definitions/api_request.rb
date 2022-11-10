Given("I am using version {int} of the API") do |int|
  @api_version = int
end

Given("I create an assessment with the following details:") do |table|
  data = table.rows_hash

  if data.key?("proceeding_types")
    data["proceeding_types"] = { 'ccms_codes': data["proceeding_types"].split(";") }
  end

  response = submit_request(:post, "assessments", @api_version, data)
  @assessment_id = response["assessment_id"]
end

Given("I add the following applicant details for the current assessment:") do |table|
  data = { "applicant": cast_values(table.rows_hash) }
  submit_request(:post, "assessments/#{@assessment_id}/applicant", @api_version, data)
end

Given("I add the following dependent details for the current assessment:") do |table|
  data = { "dependants": table.hashes.map { cast_values(_1) } }
  submit_request(:post, "assessments/#{@assessment_id}/dependants", @api_version, data)
end

Given("I add the following other_income details for {string} in the current assessment:") do |string, table|
  data = { "other_incomes": [{ "source": string, "payments": table.hashes.map { cast_values(_1) } }] }
  submit_request(:post, "assessments/#{@assessment_id}/other_incomes", @api_version, data)
end

Given("I add the following irregular_income details in the current assessment:") do |table|
  data = { "payments": table.hashes.map { cast_values(_1) } }
  submit_request(:post, "assessments/#{@assessment_id}/irregular_incomes", @api_version, data)
end

Given("I add the following outgoing details for {string} in the current assessment:") do |string, table|
  data = { "outgoings": ["name": string, "payments": table.hashes.map { cast_values(_1) }] }
  submit_request(:post, "assessments/#{@assessment_id}/outgoings", @api_version, data)
end

Given("I add the following capital details for {string} in the current assessment:") do |string, table|
  data = { string.to_s => table.hashes.map { cast_values(_1) } }
  submit_request(:post, "assessments/#{@assessment_id}/capitals", @api_version, data)
end

Given("I add the following proceeding types in the current assessment:") do |table|
  data = { "proceeding_types": table.hashes.map { cast_values(_1) } }
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version, data)
end

When("I retrieve the final assessment") do
  @response = submit_request(:get, "assessments/#{@assessment_id}", @api_version)
end

Then("I should see the following overall summary:") do |table|
  failures = []
  table.hashes.each do |row|
    result = extract_response_section(@response, @api_version, row["attribute"])
    error = validate_response(result, row["value"], row["attribute"])

    failures.append(error) if error.present?
  end

  unless failures.empty?
    failures.append "\n----\Response being validated: #{assessment.response.to_json}\n----\n"
  end

  raise_if_present(failures)
end

# To be used where the response has an array and you're asserting a block within it based on a conditional value within.
Then("I should see the following {string} details where {string}:") do |attribute, condition, table|
  response_section = extract_response_section @response, @api_version, attribute

  param, value = condition.split(":")

  selected_item = response_section.find { |item| item[param] == value }

  if selected_item.nil?
    raise "Unable to find section in response based on condition '#{condition}' for attribute '#{attribute}'. Found: #{response_section}"
  end

  failures = []
  table.hashes.each do |row|
    error = validate_response(selected_item[row["attribute"]], row["value"], attribute, condition:)

    failures.append(error) if error
  end

  unless failures.empty?
    failures.append "\n----\nSelected response being validated: #{selected_item.to_json}\n----\n"
  end

  raise_if_present(failures)
end

Then("I should see the following {string} details:") do |section_name, table|
  response_section = extract_response_section(@response, @api_version, section_name)

  failures = []
  table.hashes.each do |row|
    error = validate_response(response_section[row["attribute"]], row["value"], row["attribute"])
    failures.append(error) if error.present?
  end

  if failures.any?
    failures.append "\n----\nSelected response being validated: #{response_section.to_json}\n----\n"
  end

  raise_if_present(failures)
end
