Given("I am undertaking a standard assessment with an applicant who receives passporting benefits") do
  @api_version = 5
  response = submit_request(:post, "assessments", @api_version,
                            { client_reference_id: "N/A", submission_date: "2022-05-10" })
  @assessment_id = response["assessment_id"]
  submit_request(:post, "assessments/#{@assessment_id}/applicant", @api_version,
                 { applicant: { date_of_birth: "1979-12-20",
                                involvement_type: "applicant",
                                has_partner_opponent: false,
                                receives_qualifying_benefit: true } })
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version,
                 { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] })
end

Given("I am undertaking a standard assessment with a pensioner applicant who is not passported") do
  StateBenefitType.create! label: "housing_benefit", name: "Housing benefit", exclude_from_gross_income: true
  @api_version = 5
  response = submit_request(:post, "assessments", @api_version,
                            { client_reference_id: "N/A", submission_date: "2022-05-10" })
  @assessment_id = response["assessment_id"]
  submit_request(:post, "assessments/#{@assessment_id}/applicant", @api_version,
                 { applicant: { date_of_birth: "1939-12-20",
                                involvement_type: "applicant",
                                has_partner_opponent: false,
                                receives_qualifying_benefit: false } })
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version,
                 { "proceeding_types": [{ ccms_code: "SE003", client_involvement_type: "A" }] })
end

Given("I am undertaking a controlled work assessment with an applicant who receives passporting benefits") do
  @api_version = 5
  response = submit_request(:post, "assessments", @api_version,
                            { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_representation: "controlled" })
  @assessment_id = response["assessment_id"]
  submit_request(:post, "assessments/#{@assessment_id}/applicant", @api_version,
                 { applicant: { date_of_birth: "1979-12-20",
                                involvement_type: "applicant",
                                has_partner_opponent: false,
                                receives_qualifying_benefit: true } })
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version,
                 { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] })
end

Given("I am undertaking a controlled assessment") do
  StateBenefitType.create! label: "housing_benefit", name: "Housing benefit", exclude_from_gross_income: true
  @api_version = 5
  response = submit_request(:post, "assessments", @api_version,
                            { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_representation: "controlled" })
  @assessment_id = response["assessment_id"]
  submit_request(:post, "assessments/#{@assessment_id}/applicant", @api_version,
                 { applicant: { date_of_birth: "1989-12-20",
                                involvement_type: "applicant",
                                has_partner_opponent: false,
                                receives_qualifying_benefit: false } })
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version,
                 { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] })
end

Given("Performing a controlled assessment with first tier immigration case") do
  StateBenefitType.create! label: "housing_benefit", name: "Housing benefit", exclude_from_gross_income: true
  @api_version = 5
  response = submit_request(:post, "assessments", @api_version,
                            { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_representation: "controlled" })
  @assessment_id = response["assessment_id"]
  submit_request(:post, "assessments/#{@assessment_id}/applicant", @api_version,
                 { applicant: { date_of_birth: "1989-12-20",
                                involvement_type: "applicant",
                                has_partner_opponent: false,
                                receives_qualifying_benefit: false } })
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version,
                 { "proceeding_types": [{ ccms_code: CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE, client_involvement_type: "A" }] })
end

Given("Performing a controlled assessment with first tier asylum case") do
  StateBenefitType.create! label: "housing_benefit", name: "Housing benefit", exclude_from_gross_income: true
  @api_version = 5
  response = submit_request(:post, "assessments", @api_version,
                            { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_representation: "controlled" })
  @assessment_id = response["assessment_id"]
  submit_request(:post, "assessments/#{@assessment_id}/applicant", @api_version,
                 { applicant: { date_of_birth: "1989-12-20",
                                involvement_type: "applicant",
                                has_partner_opponent: false,
                                receives_qualifying_benefit: false } })
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version,
                 { "proceeding_types": [{ ccms_code: "IA031", client_involvement_type: "A" }] })
end

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

Given("I add the following housing benefit details for the applicant:") do |table|
  data = { state_benefits: [{ "name": "housing_benefit",
                              "payments": table.hashes.map { cast_values(_1) } }] }
  submit_request(:post, "assessments/#{@assessment_id}/state_benefits", @api_version, data)
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

Given("I add the following employment details for the partner:") do |table|
  @partner_employments = [{ "name": "A",
                            "client_id": "B",
                            "payments": table.hashes.map { cast_values(_1) } }]
end

Given("I add the following regular_transaction details for the partner:") do |table|
  @partner_regular_transactions = table.hashes.map { cast_values(_1) }
end

Given("I add the following additional property details for the partner in the current assessment:") do |table|
  @partner_property = [cast_values(table.rows_hash)]
end

Given("I add the following main property details for the current assessment:") do |table|
  @main_home = cast_values(table.rows_hash)
end

Given("I add the following additional property details for the current assessment:") do |table|
  @secondary_home = cast_values(table.rows_hash)
end

Given("I add the following proceeding types in the current assessment:") do |table|
  data = { "proceeding_types": table.hashes.map { cast_values(_1) } }
  submit_request(:post, "assessments/#{@assessment_id}/proceeding_types", @api_version, data)
end

Given("I add the following vehicle details for the current assessment:") do |table|
  data = { "vehicles": [cast_values(table.rows_hash)] }
  submit_request(:post, "assessments/#{@assessment_id}/vehicles", @api_version, data)
end

Given("I add the following capital details for {string} for the partner:") do |string, table|
  @partner_capitals = { string.to_s => table.hashes.map { cast_values(_1) } }
end

When("I retrieve the final assessment") do
  if @main_home || @secondary_home
    additional_properties = @secondary_home ? [@secondary_home] : []
    main_home = @main_home || blank_main_home
    data = { "properties": { main_home:, additional_properties: } }
    submit_request(:post, "assessments/#{@assessment_id}/properties", @api_version, data)
  end

  if @partner_employments || @partner_property || @partner_regular_transactions || @partner_capitals
    employments = @partner_employments || []
    additional_properties = @partner_property || []
    regular_transactions = @partner_regular_transactions || []
    capitals = @partner_capitals || {}
    data = { "partner": { "date_of_birth": "1992-07-22", "employed": true },
             employments:,
             additional_properties:,
             regular_transactions:,
             capitals: }
    submit_request(:post, "assessments/#{@assessment_id}/partner_financials", @api_version, data)
  end

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
    failures.append "\n----\Response being validated: #{@response.to_json}\n----\n"
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

Then("I should see the following {string} details for the partner:") do |section_name, table|
  response_section = extract_response_section(@response, @api_version, section_name)

  failures = []
  table.hashes.each do |row|
    error = validate_response(response_section.first[row["attribute"]], row["value"], row["attribute"])
    failures.append(error) if error.present?
  end
  if failures.any?
    failures.append "\n----\nSelected response being validated: #{response_section.to_json}\n----\n"
  end

  raise_if_present(failures)
end
