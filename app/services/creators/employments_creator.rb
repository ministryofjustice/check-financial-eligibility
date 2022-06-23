module Creators
  class EmploymentsCreator < BaseCreator
    def initialize(assessment_id:, employments_params:)
      super()
      @assessment_id = assessment_id
      @employments_params = employments_params
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

    def employment_attributes
      @employment_attributes ||= JSON.parse(@employments_params, symbolize_names: true)
    end

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
      employment_attributes[:employment_income].each do |employment|
        @assessment.employments.create!(assessment_id: @assessment_id,
                                        name: employment[:name],
                                        client_id: employment[:client_id])
        create_payments(employment)
      end
    end

    def create_payments(employment)
      employment[:payments].each do |income|
        emp = Employment.find_by(assessment_id: @assessment_id, name: employment[:name])
        emp.employment_payments.create!(employment_id: emp.id,
                                        client_id: income[:client_id],
                                        date: income[:date],
                                        gross_income: income[:gross],
                                        benefits_in_kind: income[:benefits_in_kind],
                                        tax: income[:tax],
                                        national_insurance: income[:national_insurance])
      end
    end

    def assessment
      @assessment ||= Assessment.find_by(id: @assessment_id) || (raise CreationError, ["No such assessment id"])
    end
  end
end
