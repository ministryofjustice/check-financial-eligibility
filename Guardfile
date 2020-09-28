guard :rubocop, all_on_start: false do
  watch(%r{//.+\.rb$//})
  watch(%r{(?:.+/)?\.(rubocop|rubocop_todo)\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'VERBOSE=true bundle exec rspec', all_on_start: false do
  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^app/interfaces/api/(.+)\.rb$}) { |m| "spec/api/#{m[1]}_spec.rb" }
  watch("spec/fixtures/integration_test_data.xlsx") { "spec/integration/test_runner_spec.rb" }
end
