class BaseCreationService
  class CreationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super
    end
  end

  attr_writer :errors

  def errors
    @errors ||= []
  end

  def self.call(*args)
    new(*args).call
  end

  def success?
    errors.empty?
  end
end
