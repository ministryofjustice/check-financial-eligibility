guard :rubocop, all_on_start: false do
  watch(%r{//.+\.rb$//})
  watch(%r{(?:.+/)?\.(rubocop|rubocop_todo)\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: "VERBOSE=true bundle exec rspec", all_on_start: false do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w[erb haml slim])
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.controllers) { |m| rspec.spec.call("requests/#{m[1]}") }

  # Rails config changes
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "#{rspec.spec_dir}/requests" }
  watch(rails.app_controller)  { "#{rspec.spec_dir}/requests" }
end
