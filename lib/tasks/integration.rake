desc 'Run integration tests in verbose mode, pass [silent] to run quiet'
task :integration, [:silent] => :environment do |_task, args|
  integration_test_file = Rails.root.join('spec/integration/test_runner_spec.rb')
  silent = args.silent.blank?
  system "VERBOSE=#{silent} bundle exec rspec #{integration_test_file}"
end
