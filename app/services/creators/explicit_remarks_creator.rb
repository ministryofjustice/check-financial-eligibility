module Creators
  class ExplicitRemarksCreator < BaseCreator
    def initialize(assessment_id:, explicit_remarks_params:)
      super()
      @assessment_id = assessment_id
      @explicit_remarks_params = explicit_remarks_params
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end
      self
    end

    def create_records
      create_remarks
    rescue CreationError => e
      errors << e.errors
    end

    def create_remarks
      ExplicitRemark.transaction do
        explicit_remarks_attributes.each do |remark_category|
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

  private

    def explicit_remarks_attributes
      @explicit_remarks_attributes ||= JSON.parse(@explicit_remarks_params, symbolize_names: true).fetch(:explicit_remarks, nil)
    end

    def json_validator
      @json_validator ||= JsonValidator.new("explicit_remarks", @explicit_remarks_params)
    end
  end
end
