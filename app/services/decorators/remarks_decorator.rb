module Decorators
  class RemarksDecorator
    attr_reader :assessment

    def initialize(record, assessment)
      @record = record
      @assessment = assessment
    end

    def as_json
      return nil if @record.nil?

      if assessment.assessment_result == 'contribution_required'
        @record.as_json
      else
        @record.as_json.except(:policy_disregards)
      end
    end
  end
end
