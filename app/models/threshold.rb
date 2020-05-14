class Threshold
  class << self
    attr_reader :data_folder_path

    def data_folder(path)
      @data_folder_path = Rails.root.join(path)
    end

    def data
      @data ||= begin
        Dir[File.join(data_folder_path, '*.yml')].each_with_object({}) do |path, hash|
          threshold = new(path)
          hash[threshold.start_at] = threshold
        end
      end
    end

    def value_for(item, at: Time.now)
      key = data.keys.select { |time| time < at }.max || data.keys.min
      threshold = data[key]
      threshold.value(item.to_sym)
    end
  end

  data_folder 'config/thresholds'.freeze

  attr_reader :path

  delegate :value, to: :store

  def initialize(path)
    @path = path
  end

  def start_at
    @start_at ||= Time.parse(name).beginning_of_day
  end

  def name
    @name ||= File.basename(path, '.yml')
  end

  def store
    @store ||= YamlStore.from_yaml_file(path)
  end
end
