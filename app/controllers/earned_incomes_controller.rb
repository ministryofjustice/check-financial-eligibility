class EarnedIncomesController < ApplicationController
  resource_description do
    short 'Add earned income details to an assessment'
    formats ['json']
    description <<-END_OF_TEXT
    == Description
      Adds details of an applicant's earned income to an assessment.

      All earned income must belong to an employment. Each employment must have
      a name.

      There are two types of earned income:

        - wage payments: each wage payment must be made up of a date and a gross
        payment. Each employment must have at least one wage payment. The date
        of each wage payment must be within the the calculation period, i.e.
        within three months prior to the submission date.

        - benefits in kind: this must be an array of monthly taxable values. Each
        monthly taxable valuable must be made up of a description (eg company car)
        and a value.

    END_OF_TEXT
  end
  api :POST, 'assessments/:assessment_id/earned_income', 'Create earned income'
  formats ['json']
  param :assessment_id, :uuid, required: true
  param :employments, Array, required: true, desc: 'Collection of employments' do
    param :name, String, required: true, desc: 'An identifying name for this employment'
    param :wages, Array, required: true, allow_blank: false, desc: 'A collection of wage payments' do
      param :date, ->(date) { Date.parse(date) > Date.today ? 'Invalid wage date' : true }, required: true, desc: 'The date of the wage payment'
      param :gross_payment, :currency, required: true, allow_blank: false, desc: 'The amount of the wage payment'
    end
    param :benefits_in_kind, Hash, required: true, allow_blank: true, desc: 'A collection of benefits in kind' do
      param :monthly_taxable_values, Array, of: Hash, required: true, allow_blank: true, desc: 'The benefits in kind'
    end
  end

  returns code: :ok, desc: 'Successful response' do
    property :objects, array_of: Object
    property :success, ['true'], desc: 'Success flag shows true'
  end
  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if creation_service.success?
      render_success objects: creation_service.gross_income_summary
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= EarnedIncomesCreationService.call(
      assessment_id: params[:assessment_id],
      employments_attributes: input[:employments]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end
