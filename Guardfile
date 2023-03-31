### RUBOCOP ###
rubocop_options = {
  cli: "-A",
  all_on_start: false,
}

guard :rubocop, rubocop_options do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

### RSPEC ###
rspec_options = {
  cmd: "VERBOSE=true bundle exec rspec",
  cmd_additional_args: "--fail-fast",
  all_on_start: false,
}

guard :rspec, rspec_options do
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

### CUCUMBER ###
cucumber_options = {
  cmd: "VERBOSE=true bundle exec cucumber",
  cmd_additional_args: "--publish-quiet",
  notification: false,
  all_after_pass: false,
  all_on_start: false,
}

guard :cucumber, cucumber_options do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { "features" }

  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || "features"
  end
end

### SWAGGER ###
swagger_options = {
  all_on_start: false,
}
guard :shell, swagger_options do
  watch(%r{^spec/requests/swagger_docs/.+\.rb}) do
    `NOCOVERAGE=1 bundle exec rake rswag:specs:swaggerize`
  end
end
