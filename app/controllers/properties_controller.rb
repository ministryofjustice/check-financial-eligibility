class PropertiesController < ApplicationController
  api :POST, 'assessments/:assessment_id/property', 'Create a property for the applicant'
  formats ['json']
  param :assessment_id, :uuid, required: true, desc: 'The assessment id to which this applicant relates'
  param :properties, Hash, required: true, desc: 'Describes information about the applicants property' do
    param :main_home, Hash, required: true, desc: "The applicant's main home" do
      param :value, :currency, required: true, desc: 'The value of this property'
      param :outstanding_mortgage, :currency, required: true, desc: 'The amount outstanding on any mortgage'
      param :percentage_owned, :currency, required: true, desc: 'The percentage share of the property which is owned by the applicant'
      param :shared_with_housing_assoc, :boolean, required: true, desc: 'Whether or not this house is shared with a housing association'
    end
    param :additional_properties, Array, required: false, desc: "The applicant's main home" do
      param :value, :currency, required: true, desc: 'The value of this property'
      param :outstanding_mortgage, :currency, required: true, desc: 'The amount outstanding on any mortgage'
      param :percentage_owned, :currency, required: true, desc: 'The percentage share of the property which is owned by the applicant'
      param :shared_with_housing_assoc, :boolean, required: true, desc: 'Whether or not this house is shared with a housing association'
    end
  end

  returns code: :ok, desc: 'Successful response' do
    property :objects, array_of: Property
    property :success, ['true'], desc: 'Success flag shows true'
  end

  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if creation_service_result.success?
      render json: {
        success: true,
        objects: creation_service_result.properties,
        errors: []
      }
    else
      render json: {
        success: false,
        objects: nil,
        errors: creation_service_result.errors
      }, status: 422
    end
  end

  private

  def creation_service_result
    @creation_service_result ||= PropertiesCreationService.call(request.raw_post)
  end
end
