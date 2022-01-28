# Usage: rake payment_periods:test_data:generate

namespace :payment_periods do
  namespace :test_data do
    desc "Generates test data for PaymentPeriodAnalyser"
    task generate: :environment do
      require Rails.root.join("spec/support/payment_dates_generator.rb")
      generator = PaymentDatesGenerator.new
      generator.run
      generator.to_csv
      puts "New CSV data written to #{PaymentDatesGenerator::FIXTURE_FILE} (#{generator.example_number} lines)."
    end
  end
end
