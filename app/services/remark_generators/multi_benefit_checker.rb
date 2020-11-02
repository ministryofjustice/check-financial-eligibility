module RemarkGenerators
  class MultiBenefitChecker
    def self.call(assessment, collection)
      new(assessment, collection).call
    end

    def initialize(assessment, collection)
      @assessment = assessment
      @collection = collection
    end

    def call
      populate_remarks if flagged?
    end

    private

    def flagged?
      @collection.map(&:flags).any?(['multi_benefit'])
    end

    def populate_remarks
      my_remarks = @assessment.remarks
      my_remarks.add(record_type, :multi_benefit, @collection.map(&:client_id))
      @assessment.update!(remarks: my_remarks)
    end

    def record_type
      @collection.first.class.to_s.underscore.tr('/', '_').to_sym
    end
  end
end
