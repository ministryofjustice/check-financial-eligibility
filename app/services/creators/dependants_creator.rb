module Creators
  class DependantsCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(dependants:, dependants_params:)
        create_dependants(dependants:, dependants_params:)
        Result.new(errors: []).freeze
      rescue ActiveRecord::RecordInvalid => e
        Result.new(errors: e.record.errors.full_messages).freeze
      end

    private

      def create_dependants(dependants:, dependants_params:)
        dependants.create!(dependants_params[:dependants])
      end
    end
  end
end
