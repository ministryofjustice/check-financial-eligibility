module Creators
  class OtherIncomesCreator < BaseCreator
    attr_accessor :assessment_id, :employments_attributes

    delegate :gross_income_summary, to: :assessment

    attr_reader :other_income_sources

    def initialize(assessment_id:, other_incomes_params:)
      super()
      @assessment_id = assessment_id
      @other_incomes_params = other_incomes_params
      @other_income_sources = []
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

    def create_records
      ActiveRecord::Base.transaction do
        assessment
        create_other_income
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_other_income
      return if other_incomes.empty?

      other_incomes.each do |other_income_source_params|
        @other_income_sources << create_other_income_source(other_income_source_params)
      end
    end

    def create_other_income_source(other_income_source_params)
      other_income_source = gross_income_summary.other_income_sources.create!(name: normalize(other_income_source_params[:source]))
      other_income_source_params[:payments].each do |payment_params|
        other_income_source.other_income_payments.create!(
          payment_date: payment_params[:date],
          amount: payment_params[:amount],
          client_id: payment_params[:client_id],
        )
      end
      other_income_source
    end

    def normalize(name)
      name.underscore.tr(" ", "_")
    end

    def other_incomes
      @other_incomes ||= JSON.parse(@other_incomes_params, symbolize_names: true).fetch(:other_incomes, nil)
    end

    def json_validator
      @json_validator ||= JsonValidator.new("other_incomes", @other_incomes_params)
    end
  end
end
