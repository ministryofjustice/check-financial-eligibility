RESPONSE_SECTION_MAPPINGS = {
  "v5" => {
    "assessment_result" => "result_summary.overall_result.result",
    "disposable_income_summary" => "result_summary.disposable_income",
    "capital summary" => "result_summary.capital",
    "capital_lower_threshold" => "result_summary.capital.proceeding_types.0.lower_threshold",
    "gross_income_upper_threshold" => "result_summary.gross_income.proceeding_types.1.upper_threshold",
    "gross_income_proceeding_types" => "result_summary.gross_income.proceeding_types",
    "main property" => "assessment.capital.capital_items.properties.main_home",
    "partner irregular income" => "assessment.partner_gross_income.irregular_income.monthly_equivalents",
    "partner_capital" => "assessment.partner_capital.capital_items.properties.additional_properties",
  },
}.freeze

def response_section_for(version, attribute)
  unless RESPONSE_SECTION_MAPPINGS.key?("v#{version}")
    raise "Provided version '#{version}' does not have any mapping defined."
  end

  api_mapping = RESPONSE_SECTION_MAPPINGS["v#{version}"]

  unless api_mapping.key?(attribute)
    raise "Provided attribute '#{attribute}' was not found in mapping for version '#{version}'. Available attributes are: #{api_mapping.map { |k, v| "#{k} => #{v}" }}"
  end

  api_mapping[attribute]
end

# Fetch the json values from within the response based on the mapping defined for the section
def extract_response_section(response, version, section_name)
  section_path = response_section_for(version, section_name)

  # Drill down into the JSON and extract the value out. Works with hash and array structures.
  relevant_section = response
  section_path.split(".").each do |key|
    key = key.to_i if relevant_section.is_a?(Array)

    if relevant_section[key].nil?
      raise "Expected to have key '#{key}' in '#{relevant_section}' using attribute '#{section_name}' with path '#{section_path}'"
    end

    relevant_section = relevant_section[key]
  end

  relevant_section
end

def raise_if_present(failures)
  raise failures.join("\n") if failures.any?
end

def validate_response(result, value, attribute, condition: nil)
  return if value.to_s == result.to_s

  condition_clause = " with condition: #{condition}" if condition

  "\n==> [#{attribute}] Value mismatch. Expected (++), Actual (--): \n++ #{value}\n-- #{result}\n\nfor attribute #{attribute}#{condition_clause}."
end
