# RSwag mixin spe helpers for "apply"
#
module SwaggerParameterHelpers
  # This is a common parameter used by all assessment components
  #
  def assessment_id_parameter
    parameter name: "assessment_id",
              in: :path,
              type: :string,
              description: "Unique identifier of the assessment"
  end
end
