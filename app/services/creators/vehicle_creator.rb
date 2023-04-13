module Creators
  class VehicleCreator
    Result = Struct.new(:errors, keyword_init: true) do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(capital_summary:, vehicles_params:)
        capital_summary.vehicles.create!(vehicles_params[:vehicles])
        Result.new(errors: []).freeze
      rescue ActiveRecord::RecordInvalid => e
        Result.new(errors: e.record.errors.full_messages).freeze
      end
    end
  end
end
