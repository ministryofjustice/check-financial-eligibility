RSpec::Matchers.define :show_all_integration_tests_passed do
  match do |integration_tests_results|
    integration_tests_results.values.uniq == [true]
  end

  failure_message do |integration_tests_results|
    msg = "Not all integration tests passed\n"
    integration_tests_results.each do |test_name, result|
      msg += sprintf("%12<test_name>s: %<result_test>s\n", test_name:, result_test: (result == true ? "PASS" : "FAIL"))
    end
    msg
  end
end
