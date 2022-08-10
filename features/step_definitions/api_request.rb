request_dispatcher = Request.new
assessment = nil

Given('I am using version {int} of the API') do |int|
  assessment = Assessment.new
  assessment.api_version int
end

Given('I create an assessment with the following details:') do |table|
  data = assessment.cleanse table.rows_hash

  if data.key?('proceeding_types')
    data['proceeding_types'] = {'ccms_codes': data['proceeding_types'].split(';')}
  end

  payload = data.to_json
  request = assessment.get_request('create_assessment', payload)
  response = request_dispatcher.process request

  assessment.id = response['assessment_id']
end

Given('I add the following applicant details for the current assessment:') do |table|
  data = {"applicant": table.rows_hash}
  data = assessment.cleanse data

  payload = data.to_json
  request = assessment.get_request('add_applicant', payload, {'id' => assessment.id})
  request_dispatcher.process request
end

Given('I add the following dependent details for the current assessment:') do |table|
  data = { "dependants": table.hashes }
  data = assessment.cleanse data

  payload = data.to_json
  request = assessment.get_request('add_dependants', payload, {'id' => assessment.id})
  request_dispatcher.process request
end

Given('I add the following other_income details for {string} in the current assessment:') do |string, table|
  data = { "other_incomes": [{"source": string, "payments": table.hashes}]}
  data = assessment.cleanse data

  payload = data.to_json
  request = assessment.get_request('add_other_incomes', payload, {'id' => assessment.id})
  request_dispatcher.process request
end

Given('I add the following irregular_income details in the current assessment:') do |table|
  data = {"payments": table.hashes}
  data = assessment.cleanse data

  payload = data.to_json
  request = assessment.get_request('add_irregular_incomes', payload, {'id' => assessment.id})
  request_dispatcher.process request
end

Given('I add the following outgoing details for {string} in the current assessment:') do |string, table|
  data = {"outgoings": ["name": string, "payments": table.hashes]}
  data = assessment.cleanse data

  payload = data.to_json
  request = assessment.get_request('add_outgoings', payload, {'id' => assessment.id})
  request_dispatcher.process request
end

Given('I add the following capital details for {string} in the current assessment:') do |string, table|
  data = { "#{string}" => table.hashes}
  data = assessment.cleanse data

  payload = data.to_json
  request = assessment.get_request('add_capitals', payload, {'id' => assessment.id})
  request_dispatcher.process request
end

Given('I add the following proceeding types in the current assessment:') do |table|
  data = { "proceeding_types": table.hashes}
  data = assessment.cleanse data

  payload = data.to_json
  request = assessment.get_request('add_proceeding_types', payload, {'id' => assessment.id})
  request_dispatcher.process request
end

When('I retrieve the final assessment') do
  request = assessment.get_request('retrieve_assessment', {}, {'id' => assessment.id})
  assessment.response = request_dispatcher.process request
end

Then('I should see the following overall summary:') do |table|
  if assessment.nil? || assessment.response.empty? || assessment.version.nil?
    raise 'The reponse and version must be set before using this step definition.'
  end

  failures = []
  table.hashes.each do | row |
    result = get_value_from_response assessment.response, assessment.version, row['attribute']
    valid_or_message = validate_response result, row['value'], assessment.version, row['attribute'], assessment_id: assessment.id

    unless valid_or_message == true
      failures.append valid_or_message
    end
  end

  unless failures.empty?
    failures.append "\n----\Response being validated: #{assessment.response.to_json}\n----\n"
  end

  print_failures failures
end

# To be used where the response has an array and you're asserting a block within it based on a conditional value within.
Then('I should see the following {string} details where {string}:') do |attribute, condition, table|
  if assessment.nil? || assessment.response.empty? || assessment.version.nil?
    raise 'The reponse and version must be set before using this step definition.'
  end

  responseSection = get_value_from_response assessment.response, assessment.version, attribute

  param, value = condition.split(':')

  selectedItem = {}
  responseSection.each do | item |
    if item[param] == value
      selectedItem = item
      break
    end
  end

  if selectedItem.empty?
    raise "Unable to find section in response based on condition '#{condition}' for attribute '#{attribute}'. Found: #{responseSection.to_s}"
  end

  failures = []
  table.hashes.each do | row |
    valid_or_message = validate_response selectedItem[row['attribute']], row['value'], assessment.version, attribute, assessment.id, condition: condition

    unless valid_or_message == true
      failures.append valid_or_message
    end
  end

  unless failures.empty?
    failures.append "\n----\nSelected response being validated: #{selectedItem.to_json}\n----\n"
  end

  print_failures failures
end
