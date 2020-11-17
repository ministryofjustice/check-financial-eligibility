module RemarkGenerators
  class MultiBenefitChecker < BaseChecker
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
  end
end
