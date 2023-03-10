module Creators
  class EmploymentsCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end
    class << self
      def call(employments_params:, employment_collection:)
        json_validator = JsonValidator.new("employment", employments_params)
        if json_validator.valid?
          create_records employments_params, employment_collection
        else
          Result.new(errors: json_validator.errors).freeze
        end
      end

  private

      def create_records(employments_params, employment_collection)
        ActiveRecord::Base.transaction do
          create_employment employments_params, employment_collection
          Result.new(errors: []).freeze
        rescue ActiveRecord::RecordInvalid => e
          Result.new(errors: [e.message]).freeze
        end
      end

      def create_employment(employments_params, employment_collection)
        employments_params[:employment_income].each do |attributes|
          employment = employment_collection.create!(attributes.slice(:name, :client_id, :receiving_only_statutory_sick_or_maternity_pay))
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
  end
  end
end
