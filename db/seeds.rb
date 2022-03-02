# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Rails.logger.info "Seeding started"
Seeder = Dibber::Seeder

DELETED_STATE_BENEFITS = %w[
  transfer_advances_of_universal_credit
  care_in_the_community_direct_payment
  widows_pension
  social_fund
  social_fund_funderal_payment
  lump_sum_payments_under_windows_pension
].freeze

StateBenefitType.where(label: DELETED_STATE_BENEFITS).map(&:destroy!)

Seeder.new(StateBenefitType, "data/state_benefit_types.yml", name_method: :label, overwrite: true).build

Rails.logger.debug Seeder.report
Rails.logger.info Seeder.report.join("\n")
Rails.logger.info "Seeding completed"
