class DependantsController < ApplicationController
  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::DependantsCreator.call(
      assessment_id: params[:assessment_id],
      dependants_params:,
    )
  end

  def dependants_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
