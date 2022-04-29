class RequestLog < ApplicationRecord
  def self.create_from_request(request)
    create!(request_method: request.request_method,
            endpoint: request.path,
            assessment_id: request.params["assessment_id"] || request.params["id"],
            params: request.params.to_s)
  end

  def update_from_response(response, duration)
    self.assessment_id = JSON.parse(response.body)["assessment_id"] if assessment_id.nil?

    self.http_status = response.status
    self.response =  response.body
    self.duration =  duration
    save!
  end
end
