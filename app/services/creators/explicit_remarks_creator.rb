module Creators
  class ExplicitRemarksCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(assessment:, explicit_remarks_params:)
        create_remarks(assessment:, explicit_remarks_params:)
        Result.new(errors: []).freeze
      rescue ActiveRecord::RecordInvalid => e
        Result.new(errors: e.record.errors.full_messages).freeze
      end

    private

      def create_remarks(assessment:, explicit_remarks_params:)
        ExplicitRemark.transaction do
          explicit_remarks_attributes(explicit_remarks_params:).each do |remark_category|
            create_remark_category(remark_category, assessment)
          end
        end
      end

      def create_remark_category(remark_category, assessment)
        category = remark_category[:category]
        remarks = remark_category[:details]
        remarks.each { |remark| create_remark(category, remark, assessment) }
      end

      def create_remark(category, remark, assessment)
        ExplicitRemark.create!(assessment:,
                               category:,
                               remark:)
      end

      def explicit_remarks_attributes(explicit_remarks_params:)
        explicit_remarks_params.fetch(:explicit_remarks, nil)
      end
    end
  end
end
