module Creators
  class EmploymentsCreator < BaseCreator
    def initialize(assessment_id:, employments_params:, employment_collection: nil)
      super()
      @assessment_id = assessment_id
      @employments_params = employments_params
      @explicit_employment_collection = employment_collection
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end
      self
    end

  private

    def json_validator
      @json_validator ||= JsonValidator.new("employment", @employments_params)
    end

    def create_records
      ActiveRecord::Base.transaction do
        assessment
        create_employment
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_employment
      @employments_params[:employment_income].each do |attributes|
        employment = employment_collection.create!(attributes.slice(:name, :client_id))
        create_payments(employment, attributes)
      end
    end

    def create_payments(employment, attributes)
      attributes[:payments].each do |income|
        employment.employment_payments.create!(client_id: income[:client_id],
                                               date: income[:date],
                                               gross_income: income[:gross],
                                               benefits_in_kind: income[:benefits_in_kind],
                                               tax: income[:tax],
                                               national_insurance: income[:national_insurance])
      end
    end

    def employment_collection
      @explicit_employment_collection || assessment.employments
    end
  end
end
