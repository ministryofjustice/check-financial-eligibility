class ApiResponse
  include ActiveModel::Serialization

  attr_accessor :success, :objects, :errors

  def self.success(objects)
    response = new
    response.success = true
    response.objects = objects
    response
  end

  def self.error(messages)
    response = new
    response.success = false
    response.errors = messages
    response
  end

  def success?
    raise 'ApiResponse object is in incomplete state' if @success.nil?

    @success
  end
end
