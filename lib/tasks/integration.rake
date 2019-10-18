desc 'Run integration tests only in verbose mode'
task integration: :environment do
  integration_test_file = Rails.root.join('spec/services/integration_tests/test_runner_spec.rb')
  system "VERBOSE=true bundle exec rspec #{integration_test_file}"
end
