namespace :test do
  desc 'Generate API documentation'
  task generate_docs: :environment do
    `APIPIE_RECORD=examples bundle exec rspec`
  end
end
