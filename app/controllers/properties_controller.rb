class PropertiesController < ApplicationController
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
      additional_properties_attributes: input.dig(:properties, :additional_properties),
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end
