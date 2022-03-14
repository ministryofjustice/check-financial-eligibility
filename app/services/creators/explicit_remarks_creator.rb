module Creators
  class ExplicitRemarksCreator < BaseCreator
    def initialize(assessment_id:, remarks_attributes: nil)
      super()
      @assessment_id = assessment_id
      @remarks_attributes = remarks_attributes
    end

    def call
      create_records
      self
    end

    def create_records
      create_remarks
    rescue CreationError => e
      errors << e.errors
    end

    def create_remarks
      ExplicitRemark.transaction do
        @remarks_attributes.each do |remark_category|
          create_remark_category(remark_category)
        end
      end
    rescue StandardError => e
      raise CreationError, "#{e.class} - #{e.message}"
    end

    def create_remark_category(remark_category)
      category = remark_category[:category]
      remarks = remark_category[:details]
      remarks.each { |remark| create_remark(category, remark) }
    end

    def create_remark(category, remark)
      rec = ExplicitRemark.create(assessment_id: @assessment_id,
                                  category:,
                                  remark:)
      return if rec.valid? && rec.persisted?

      @errors = rec.errors.full_messages
      raise ActiveRecord::Rollback
    end
  end
end
