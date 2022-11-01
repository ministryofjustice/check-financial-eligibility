require "open3"

# Any universal setup
BeforeAll do
  puts "runs once before all features...check this though"
  # run demonoized rails server against test database
  system("RAILS_ENV=test rails s -p 3456 -P 'tmp/pids/feature-test.pid' -d")
end

# Any cleanup
AfterAll do
  Open3.popen3("cat", "tmp/pids/feature-test.pid") do |_stdin, stdout, _stderr, _wait_thr|
    pid = stdout.gets
    puts "\"Terminating rails server #{pid}\""
    `kill -s sigterm #{pid}`
  end

  puts "runs once after all features...check this though"
end
