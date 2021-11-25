class EmploymentsController < ApplicationController
  resource_description do
    name 'Employments'
    short "Add details of an applicant's employment to an assessment"
    formats(%w[json])
    description <<-END_OF_TEXT
    == Description
      Adds details of an applicant's employment/earned income to an assessment.
    END_OF_TEXT
  end

  api :POST, 'assessments/:assessment_id/employments', 'Create employment record'
  formats(%w[json])
  param :assessment_id, :uuid, required: true
  param :employment_income, Array, of: Hash, desc: 'Collection of employment and income financial information' do
    param :name, String, required: true, desc: 'An identifying name for this employment e.g. employer name'
    param :payments, Array, of: Hash, required: true, desc: 'A collection of information about income from the employment' do
      param :date, Date, date_option: :today_or_older, required: true, desc: 'The date payment received'
      param :gross, :currency, currency_option: :not_negative, required: true, desc: 'Gross income received figure'
      param :benefits_in_kind, :currency, currency_option: :not_negative, required: true, desc: 'Benefit in kind amount'
      param :tax, :currency, required: true, desc: 'Amount of tax paid'
      param :national_insurance, :currency, required: true, desc: 'Amount of national insurance paid'
      param :net_employment_income, :currency, currency_option: :not_negative, required: true, desc: 'Net income received figure'
    end
  end

  returns code: :ok, desc: 'Successful response' do
    property :success, ['true'], desc: 'Success flag shows true'
    property :errors, [], desc: 'Empty array of error messages'
  end
  returns code: :unprocessable_entity do
    property :success, ['false'], desc: 'Success flag shows false'
    property :errors, array_of: String, desc: 'Description of why object invalid'
  end

  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= Creators::EmploymentsCreator.call(
      assessment_id: params[:assessment_id],
      employments_attributes: input[:employment_income]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end
