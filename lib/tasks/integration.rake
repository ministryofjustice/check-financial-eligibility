desc 'Run integration tests in verbose mode, pass [silent] to run quiet, [noisy] to run extra noisy or nothing for normal noisiness'
task :integration, [:silent] => :environment do |_task, args|
  integration_test_file = Rails.root.join('spec/integration/test_runner_spec.rb')
  verbosity = if args.silent == 'noisy'
                'noisy'
              else
                args.silent.blank?
              end
  system "VERBOSE=#{verbosity} bundle exec rspec #{integration_test_file}"
end
