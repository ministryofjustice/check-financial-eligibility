def post(uri, payload, headers)
  Capybara.page.driver.post(Capybara.app_host + uri, payload, headers)

  Capybara.page.body
end

def get(uri, headers)
  Capybara.page.driver.get(Capybara.app_host + uri, headers)

  Capybara.page.body
end

def print_failures(failures)
  unless failures.empty?
    raise failures.join("\n")
  end
end

def validate_response(result, value, version = nil, attribute = nil, assessment_id = nil, condition = "")
  if value.to_s != result.to_s
    return "\n==> [#{attribute}] Value mismatch. Expected (++), Actual (--): \n++ #{value}\n-- #{result}" unless version && attribute

    mapping = get_mapping version, attribute
    unless condition.empty?
      attribute += ".X/where[#{condition}"
    end

    return "\n==> [#{attribute}] Value mismatch. Expected (++), Actual (--): \n++ #{value}\n-- #{result}\n\nmapping to '#{mapping}' in the JSON response. Assessment id '#{assessment_id}'"
  end

  true
end
