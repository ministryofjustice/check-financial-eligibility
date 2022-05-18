class ApplicantsController < ApplicationController
  # resource_description do
  #   description <<-END_OF_TEXT
  #   == Description
  #     This endpoint will create an Applicant and associate it with
  #     an existing Assessment which has been created with:

  #       POST /assessments

  #   END_OF_TEXT
  # end
  # api :POST, "assessments/:assessment_id/applicant", "Create Applicant and attach it to an existing Assessment (create assessment first with POST /assessments)"
  # formats(%w[json])
  # param :assessment_id, :uuid, required: true, desc: "The assessment id to which this applicant relates - must have been created prior to this call with POST /assessments"
  # param :applicant, Hash, desc: "Describes basic info about the applicant", required: true do
  #   param :date_of_birth, Date, date_option: :today_or_older, required: true, desc: "The applicant's date of birth"
  #   param :involvement_type, Applicant.involvement_types.values, required: true, desc: "How the applicant is involved in the case"
  #   param :has_partner_opponent, :boolean, required: true, desc: "Whether or not the applicant's partner is an opponent in the case"
  #   param :receives_qualifying_benefit, :boolean, required: true, desc: "Whether or not the applicant receives a qualifying benefit"
  # end

  # returns code: :ok, desc: "Successful response" do
  #   property :success, %w[true], desc: "Success flag shows true"
  #   property :errors, [], desc: "Empty array of error messages"
  # end
  # returns code: :unprocessable_entity do
  #   property :success, %w[false], desc: "Success flag shows false"
  #   property :errors, array_of: String, desc: "Description of why object invalid"
  # end

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
    "public/schemas/applicant_schema.json"
  end
end
