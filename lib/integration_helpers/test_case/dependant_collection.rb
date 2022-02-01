module TestCase
  class DependantCollection
    def initialize(rows)
      @dependants = []
      populate_dependants(rows)
    end

    def url_method
      :assessment_dependants_path
    end

    def payload
      {
        dependants: @dependants.map(&:payload),
      }
    end

    def empty?
      @dependants.empty?
    end

  private

    def populate_dependants(rows)
      loop do
        dependant_data = rows.shift(5)
        dependant = Dependant.new(dependant_data)
        @dependants << dependant unless dependant.all_nil?
        break unless rows.first[0].nil?
      end
    end
  end
end
