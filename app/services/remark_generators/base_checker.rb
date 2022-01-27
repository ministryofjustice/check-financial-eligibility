module RemarkGenerators
  class BaseChecker
    def self.call(assessment, collection)
      new(assessment, collection).call
    end

    def initialize(assessment, collection)
      @assessment = assessment
      @collection = collection
    end

  private

    def record_type
      @collection.first.class.to_s.underscore.tr('/', '_').to_sym
    end
  end
end
