module Decorators
  module V3
    class RemarksDecorator
      def initialize(record, assessment)
        @record = record
        @assessment = assessment
      end

      def as_json
        return if @record.nil?

        contribution_required? ? @record.as_json : @record.as_json.except!(:policy_disregards)
      end

    private

      def contribution_required?
        @assessment.assessment_result == "contribution_required"
      end
    end
  end
end
