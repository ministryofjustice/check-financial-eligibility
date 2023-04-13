class CreationController < ApplicationController
private

  def json_validate_and_render(schema_name, parameters, creator)
    validate_and_render JsonValidator.new(schema_name, parameters), creator
  end

  def swagger_validate_and_render(schema_name, parameters, creator)
    validate_and_render JsonSwaggerValidator.new(schema_name, parameters), creator
  end

  def validate_and_render(json_validator, creator)
    if json_validator.valid?
      result = creator.call
      if result.success?
        render_success
      else
        render_unprocessable(result.errors)
      end
    else
      render_unprocessable(json_validator.errors)
    end
  end

  def validate_swagger_schema(schema_name, parameters)
    json_validator = JsonSwaggerValidator.new(schema_name, parameters)
    unless json_validator.valid?
      render_unprocessable(json_validator.errors)
    end
  end

  def validate_json_schema(schema_name, parameters)
    json_validator = JsonValidator.new(schema_name, parameters)
    unless json_validator.valid?
      render_unprocessable(json_validator.errors)
    end
  end
end
