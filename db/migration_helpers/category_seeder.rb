module MigrationHelpers
  class CategorySeeder
    SEED_FILENAME = Rails.root.join('db/seeds/data/state_benefit_types.yml')

    def self.call
      new.run
    end

    def initialize
      @seed_data = YAML.load_file(SEED_FILENAME)
    end

    def run
      @seed_data.each do |label, data|
        record = StateBenefitType.find_by(label: label)
        record.nil? ? insert_record(label, data) : update_record(record, data)
      end
    end

    private

    def insert_record(label, data)
      data[:label] = label
      StateBenefitType.create!(data)
      puts "Record inserted for #{label}"
    end

    def update_record(record, data)
      return if no_change(record, data)

      record.update!(data)
      puts "Record updated for #{record.label}"
    end

    def no_change(record, data)
      attrs = record.attributes.symbolize_keys.except(:id, :created_at, :updated_at)
      attrs == data
    end
  end
end
