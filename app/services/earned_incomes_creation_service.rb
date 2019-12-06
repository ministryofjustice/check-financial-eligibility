class EarnedIncomesCreationService < BaseCreationService
  attr_accessor :assessment_id, :employments_attributes

  delegate :gross_income_summary, to: :assessment

  def initialize(assessment_id:, employments_attributes: nil)
    @assessment_id = assessment_id
    @employments_attributes = employments_attributes
  end

  def call
    create
    self
  end

  private

  def create
    ActiveRecord::Base.transaction do
      assessment
      create_earned_income
    rescue CreationError => e
      self.errors = e.errors
    end
  end

  def create_earned_income
    return if @employments_attributes.blank?

    @employments_attributes.each do |attrs|
      employment = gross_income_summary.employments.create!(name: attrs[:name])
      create_wage_payments(employment, attrs[:wages])
      benefits_in_kind_array = attrs[:benefits_in_kind][:monthly_taxable_values]
      create_benefits_in_kind(employment, benefits_in_kind_array) unless benefits_in_kind_array.empty?
    end
  end

  def create_wage_payments(employment, wages)
    wages.each do |wage|
      employment.wage_payments.create!(date: wage[:date], gross_payment: wage[:gross_payment])
    end
  end

  def create_benefits_in_kind(employment, benefits_in_kind)
    benefits_in_kind.first.each do |benefit_in_kind|
      employment.benefit_in_kinds.create!(description: benefit_in_kind.first.to_s.humanize, value: benefit_in_kind.second)
    end
  end

  def assessment
    @assessment ||= Assessment.find_by(id: assessment_id) || (raise CreationError, ['No such assessment id'])
  end
end
