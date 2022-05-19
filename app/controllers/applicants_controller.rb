class ApplicantsController < ApplicationController
  def create
    return render_unprocessable(json_validator.errors) unless json_validator.valid?

    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::ApplicantCreator.call(
      assessment_id: params[:assessment_id],
      applicant_attributes: input[:applicant],
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end

  def json_validator
    @json_validator ||= JsonValidator.new(schema, request.raw_post)
  end

  def schema
    @schema ||= "applicant"
  end
end
