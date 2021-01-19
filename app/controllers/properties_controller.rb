class PropertiesController < ApplicationController
  api :POST, 'assessments/:assessment_id/properties', 'Create a property for the applicant'
  formats(%w[json])
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
      param :outstanding_mortgage, :currency, currency_option: :not_negative, required: true, desc: 'The amount outstanding on any mortgage'
      param :percentage_owned, :currency, required: true, desc: 'The percentage share of the property which is owned by the applicant'
      param :shared_with_housing_assoc, :boolean, required: true, desc: 'Whether or not this house is shared with a housing association'
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
    @creation_service ||= Creators::PropertiesCreator.call(
      assessment_id: params[:assessment_id],
      main_home_attributes: input.dig(:properties, :main_home),
      additional_properties_attributes: input.dig(:properties, :additional_properties)
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end
