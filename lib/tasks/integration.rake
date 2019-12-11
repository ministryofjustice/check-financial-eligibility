namespace :integration do
  desc 'Run integration tests only in verbose mode'
  task verbose: :environment do
    integration_test_file = Rails.root.join('spec/integration/test_runner_spec.rb')
    system "VERBOSE=true bundle exec rspec #{integration_test_file}"
  end

  desc 'Run integration tests only in silent mode'
  task silent: :environment do
    integration_test_file = Rails.root.join('spec/integration/test_runner_spec.rb')
    system "VERBOSE=false bundle exec rspec #{integration_test_file}"
  end
end
