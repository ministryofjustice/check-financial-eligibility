class ExplicitRemarksController < ApplicationController
  resource_description do
    description <<-END_OF_TEXT
    == Description
      This endpoint will allow remarks to be sent to CFE which will be included in the
      assessment result

        POST /remarks

    END_OF_TEXT
  end
  api :POST, 'assessments/:assessment_id/explicit_remarks', 'Add remarks to an assessment (create assessment first with POST /assessments)'
  formats ['json']
  param :assessment_id, :uuid, required: true, desc: 'The assessment id to which these remarks relate - must have been created prior to this call with POST /assessments'
  param :explicit_remarks, Array, required: true, desc: 'An Array of Objects describing a a category or remarks' do
    param :category, CFEConstants::VALID_REMARK_CATEGORIES, required: true, desc: "The category of remark. Currently, only 'income disregard' is supported"
    param :details, Array, of: String, required: true
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
    creation_service
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= Creators::ExplicitRemarksCreator.call(
      assessment_id: params[:assessment_id],
      remarks_attributes: params[:explicit_remarks]
    )
  end
end
