module Decorators
  module V4
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
        @assessment.proceeding_type_codes.each { |ptc| add_matter_type(ptc) }
        @matter_types_hash.keys.sort.map do |matter_type|
          {
            matter_type: matter_type,
            result: @matter_types_hash[matter_type]
          }
        end
      end

      def add_matter_type(ptc)
        matter_type = ProceedingTypeThreshold.matter_type(ptc)
        if @matter_types_hash.key?(matter_type)
          raise "Different results for matter type #{matter_type}" unless @matter_types_hash[matter_type] == result(ptc)
        else
          @matter_types_hash[matter_type] = result(ptc)
        end
      end

      def result(ptc)
        elig = @assessment.eligibilities.find_by(proceeding_type_code: ptc)
        elig.assessment_result
      end
    end
  end
end
