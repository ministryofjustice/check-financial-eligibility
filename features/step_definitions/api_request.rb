Given("I am undertaking a certificated assessment") do
  StateBenefitType.create! label: "housing_benefit", name: "Housing benefit", exclude_from_gross_income: true
  @assessment_data = { client_reference_id: "N/A", submission_date: "2022-05-10" }
  @applicant_data = { applicant: { date_of_birth: "1979-12-20",
                                   involvement_type: "applicant",
                                   has_partner_opponent: false,
                                   receives_qualifying_benefit: false } }
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "SE003", client_involvement_type: "A" }] }
end

Given("An applicant who receives passporting benefits") do
  @applicant_data.merge! applicant: @applicant_data.fetch(:applicant).merge(receives_qualifying_benefit: true)
end

Given("An applicant who is a pensioner") do
  @applicant_data.merge! applicant: @applicant_data.fetch(:applicant).merge(date_of_birth: "1939-12-20")
end

Given("A submission date of {string}") do |date|
  @assessment_data.merge! submission_date: date
end

Given("I am undertaking a controlled assessment") do
  StateBenefitType.create! label: "housing_benefit", name: "Housing benefit", exclude_from_gross_income: true
  @assessment_data = { client_reference_id: "N/A", submission_date: "2022-05-10", level_of_help: "controlled" }
  @applicant_data = { applicant: { date_of_birth: "1989-12-20",
                                   involvement_type: "applicant",
                                   has_partner_opponent: false,
                                   receives_qualifying_benefit: false } }
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] }
end

Given("A domestic abuse case") do
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "DA001", client_involvement_type: "A" }] }
end

Given("A first tier immigration case") do
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE, client_involvement_type: "A" }] }
end

Given("A first tier asylum case") do
  @proceeding_type_data = { "proceeding_types": [{ ccms_code: "IA031", client_involvement_type: "A" }] }
end

Given("I am using version {int} of the API") do |int|
  @api_version = int
  @capitals_data = {}
end

Given("I create an assessment with the following details:") do |table|
  data = table.rows_hash

  if data.key?("proceeding_types")
    data["proceeding_types"] = { 'ccms_codes': data["proceeding_types"].split(";") }
  end

  @assessment_data = data
end

Given("I add the following applicant details for the current assessment:") do |table|
  @applicant_data = { "applicant": cast_values(table.rows_hash) }
end

Given("I add the following dependent details for the current assessment:") do |table|
  @dependant_data = { "dependants": table.hashes.map { cast_values(_1) } }
end

Given("I add the following other_income details for {string} in the current assessment:") do |string, table|
  @other_incomes_data = { "other_incomes": [{ "source": string, "payments": table.hashes.map { cast_values(_1) } }] }
end

Given("I add the following housing benefit details for the applicant:") do |table|
  @benefits_data = { state_benefits: [{ "name": "housing_benefit",
                                        "payments": table.hashes.map { cast_values(_1) } }] }
end

Given("I add the following irregular_income details in the current assessment:") do |table|
  @irregular_income_data = { "payments": table.hashes.map { cast_values(_1) } }
end

Given("I add the following outgoing details for {string} in the current assessment:") do |string, table|
  @outgoings_data = { "outgoings": ["name": string, "payments": table.hashes.map { cast_values(_1) }] }
end

Given("I add the following capital details for {string} in the current assessment:") do |string, table|
  capitals_data = { string.to_s => table.hashes.map { cast_values(_1) } }
  @capitals_data.merge! capitals_data
end

Given("I add the following statutory sick pay details for the client:") do |table|
  @employments = [{ "name": "A",
                    "client_id": "B",
                    "receiving_only_statutory_sick_or_maternity_pay": true,
                    "payments": table.hashes.map { cast_values(_1) } }]
  @applicant_data = { applicant: @applicant_data.fetch(:applicant).merge(employed: true) }
end

Given("I add the following employment details for the partner:") do |table|
  @partner_employments = [{ "name": "A",
                            "client_id": "B",
                            "payments": table.hashes.map { cast_values(_1) } }]
end

Given("I add the following employment details:") do |table|
  @employments = [{ "name": "A",
                    "client_id": "B",
                    "payments": table.hashes.map { cast_values(_1) } }]
  @applicant_data = { applicant: @applicant_data.fetch(:applicant).merge(employed: true) }
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
  @proceeding_type_data = { "proceeding_types": table.hashes.map { cast_values(_1) } }
end

Given("I add the following vehicle details for the current assessment:") do |table|
  @vehicle_data = { "vehicles": [cast_values(table.rows_hash)] }
end

Given("I add the following capital details for {string} for the partner:") do |string, table|
  @partner_capitals = { string.to_s => table.hashes.map { cast_values(_1) } }
end

When("I retrieve the final assessment") do
  if @main_home || @secondary_home
    additional_properties = @secondary_home ? [@secondary_home] : []
    main_home = @main_home || blank_main_home
    main_home_data = { "properties": { main_home:, additional_properties: } }
  end

  if @employments
    employments_data = { employment_income: @employments }
  end

  if @partner_employments || @partner_property || @partner_regular_transactions || @partner_capitals
    employments = @partner_employments || []
    additional_properties = @partner_property || []
    regular_transactions = @partner_regular_transactions || []
    capitals = @partner_capitals || {}
    partner_data = { "partner": { "date_of_birth": "1992-07-22", "employed": true },
                     employments:,
                     additional_properties:,
                     regular_transactions:,
                     capitals: }
  end

  response = submit_request(:post, "assessments", @api_version, @assessment_data)
  assessment_id = response["assessment_id"]
  submit_request(:post, "assessments/#{assessment_id}/proceeding_types", @api_version, @proceeding_type_data)
  submit_request(:post, "assessments/#{assessment_id}/applicant", @api_version, @applicant_data)
  submit_request(:post, "assessments/#{assessment_id}/dependants", @api_version, @dependant_data) if @dependant_data

  submit_request(:post, "assessments/#{assessment_id}/employments", @api_version, employments_data) if employments_data
  submit_request(:post, "assessments/#{assessment_id}/other_incomes", @api_version, @other_incomes_data) if @other_incomes_data
  submit_request(:post, "assessments/#{assessment_id}/irregular_incomes", @api_version, @irregular_income_data) if @irregular_income_data
  submit_request(:post, "assessments/#{assessment_id}/state_benefits", @api_version, @benefits_data) if @benefits_data

  submit_request(:post, "assessments/#{assessment_id}/outgoings", @api_version, @outgoings_data) if @outgoings_data

  submit_request(:post, "assessments/#{assessment_id}/properties", @api_version, main_home_data) if main_home_data
  submit_request(:post, "assessments/#{assessment_id}/vehicles", @api_version, @vehicle_data) if @vehicle_data
  submit_request(:post, "assessments/#{assessment_id}/capitals", @api_version, @capitals_data) if @capitals_data

  submit_request(:post, "assessments/#{assessment_id}/partner_financials", @api_version, partner_data) if partner_data

  @response = submit_request(:get, "assessments/#{assessment_id}", @api_version)

  single_shot_api_data = { assessment: @assessment_data }
                           .merge(@applicant_data)
                           .merge(@proceeding_type_data)
  single_shot_api_data.merge!(@dependant_data) if @dependant_data
  single_shot_api_data.merge!(employments_data) if employments_data
  single_shot_api_data.merge!(@other_incomes_data) if @other_incomes_data
  single_shot_api_data[:irregular_incomes] = @irregular_income_data if @irregular_income_data
  single_shot_api_data.merge!(@benefits_data) if @benefits_data

  single_shot_api_data.merge!(@outgoings_data) if @outgoings_data

  single_shot_api_data.merge!(main_home_data) if main_home_data
  single_shot_api_data.merge!(@vehicle_data) if @vehicle_data
  single_shot_api_data[:capitals] = @capitals_data if @capitals_data
  single_shot_api_data[:partner] = partner_data if partner_data

  @single_shot_response = submit_request :post, "/v6/assessments", @api_version, single_shot_api_data
end

Then("I should see the following overall summary:") do |table|
  failures = []
  table.hashes.each do |row|
    result = extract_response_section(@response, @single_shot_response, @api_version, row["attribute"])
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
  response_section = extract_response_section @response, @single_shot_response, @api_version, attribute

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
  response_section = extract_response_section(@response, @single_shot_response, @api_version, section_name)

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
  response_section = extract_response_section(@response, @single_shot_response, @api_version, section_name)

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
