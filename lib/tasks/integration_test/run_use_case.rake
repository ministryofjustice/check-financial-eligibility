# bin/rails integration_test:run_use_case['Passported - Test 1']
namespace :integration_test do
  desc 'Run integration test with data from worksheet'
  task :run_use_case, [:worksheet] => :environment do |_task, args|
    IntegrationTest.call(args.worksheet)
  end
end
