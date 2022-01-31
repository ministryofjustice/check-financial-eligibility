module MigrationHelpers
  class CategorySeeder
    DELETED_STATE_BENEFITS = %w[
      transfer_advances_of_universal_credit
      care_in_the_community_direct_payment
      widows_pension
      social_fund
      social_fund_funderal_payment
      lump_sum_payments_under_windows_pension
    ].freeze

    def self.call
      new.run
    end

    def run
      StateBenefitType.where(label: DELETED_STATE_BENEFITS).map(&:destroy!)
      Dibber::Seeder.new(StateBenefitType, "data/state_benefit_types.yml", name_method: :label, overwrite: true).build
      puts Dibber::Seeder.report
      Rails.logger.info Dibber::Seeder.report.join("\n")
      Rails.logger.info "Seeding completed"
    end
  end
end
