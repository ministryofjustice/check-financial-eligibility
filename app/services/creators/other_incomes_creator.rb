module Creators
  class OtherIncomesCreator < BaseCreator
    attr_accessor :assessment_id, :employments_attributes

    delegate :gross_income_summary, to: :assessment

    attr_reader :other_income_sources

    def initialize(assessment_id:, other_incomes: [])
      super()
      @assessment_id = assessment_id
      @other_incomes = other_incomes[:other_incomes]
      @other_income_sources = []
    end

    def call
      create_records
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
      return if @other_incomes.empty?

      @other_incomes.each do |other_income_source_params|
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

    def assessment
      @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ["No such assessment id"])
    end

    def normalize(name)
      name.underscore.tr(" ", "_")
    end
  end
end
