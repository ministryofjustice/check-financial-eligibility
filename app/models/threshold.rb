class Threshold
  class << self
    def data
      @data ||= load_data
    end

    def load_data
      data = {}
      index = YAML.load_file(Rails.root.join(data_folder_path, 'values.yml'))
      index.each do |date, filename|
        hash = YAML.load_file(Rails.root.join(filename)).deep_symbolize_keys
        data[date.beginning_of_day] = hash if threshold_loadable?(hash)
      end
      data
    end

    def value_for(item, at: Time.now)
      key = data.keys.select { |time| time <= at }.max || data.keys.min
      threshold = data[key]
      threshold[item.to_sym]
    end

    def data_folder_path=(new_path)
      @data_folder_path = new_path
      @data = nil
    end

    def data_folder_path
      @data_folder_path ||= Rails.root.join('config/thresholds')
    end

    def threshold_loadable?(hash)
      return true unless hash.key?(:test_only)

      HostEnv.environment != :production
    end
  end
end
