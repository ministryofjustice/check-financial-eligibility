module V2
  class AssessmentsController < ApplicationController
    def create
      create = Creators::FullAssessmentCreator.call(remote_ip: request.remote_ip,
                                                    params: JSON.parse(request.raw_post, symbolize_names: true))

      if create.success?
        calculation_output = Workflows::MainWorkflow.call(create.assessment)
        render json: Decorators::V5::AssessmentDecorator.new(create.assessment, calculation_output).as_json
      else
        render_unprocessable(create.errors)
      end
    end
  end
end
