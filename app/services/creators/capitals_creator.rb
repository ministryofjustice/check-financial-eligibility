module Creators
  class CapitalsCreator
    class << self
      def call(capital_params:, capital_summary:)
        ActiveRecord::Base.transaction do
          create_liquid_assets capital_summary, capital_params[:bank_accounts]
          create_non_liquid_assets capital_summary, capital_params[:non_liquid_capital]
        end
      end

    private

      def create_liquid_assets(capital_summary, bank_accounts_attributes)
        return if bank_accounts_attributes.nil?

        bank_accounts_attributes.each do |attrs|
          capital_summary.liquid_capital_items.create!(attrs.slice(:value, :description, :subject_matter_of_dispute))
        end
      end

      def create_non_liquid_assets(capital_summary, non_liquid_capital_attributes)
        return if non_liquid_capital_attributes.nil?

        non_liquid_capital_attributes.each do |attrs|
          capital_summary.non_liquid_capital_items.create!(attrs.slice(:value, :description, :subject_matter_of_dispute))
        end
      end
    end
  end
end
