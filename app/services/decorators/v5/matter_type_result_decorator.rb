module Decorators
  module V5
    class MatterTypeResultDecorator
      def initialize(assessment)
        @assessment = assessment
        @matter_types_hash = {}
      end

      def as_json
        collate_results
      end

    private

      def collate_results
        @assessment.proceeding_types.each { |proceeding_type| add_matter_type(proceeding_type) }
        @matter_types_hash.keys.sort.map do |matter_type|
          {
            matter_type:,
            result: @matter_types_hash[matter_type],
          }
        end
      end

      def add_matter_type(proceeding_type)
        matter_type = ProceedingTypeThreshold.matter_type(proceeding_type.ccms_code)
        if @matter_types_hash.key?(matter_type)
          raise "Different results for matter type #{matter_type}" unless @matter_types_hash[matter_type] == result(proceeding_type)
        else
          @matter_types_hash[matter_type] = result(proceeding_type)
        end
      end

      def result(proceeding_type)
        elig = @assessment.eligibilities.find_by(proceeding_type_code: proceeding_type.ccms_code)
        elig.assessment_result
      end
    end
  end
end
