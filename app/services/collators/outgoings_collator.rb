module Collators
  class OutgoingsCollator
    class << self
      def call(submission_date:, person:, gross_income_summary:, disposable_income_summary:, eligible_for_childcare:, allow_negative_net:)
        # sets child_care_bank and child_care_cash fields in disposable_income_summary
        Collators::ChildcareCollator.call(gross_income_summary:,
                                          disposable_income_summary:,
                                          eligible_for_childcare:)
        # sets dependant_allowance on each dependant,
        # and dependant_allowance on disposable_income_summary as the sum of them
        Collators::DependantsAllowanceCollator.call(dependants: person.dependants,
                                                    disposable_income_summary:,
                                                    submission_date:)
        # sets maintenance_out_bank on disposable_income_summary
        Collators::MaintenanceCollator.call(disposable_income_summary)
        # sets housing_benefit, gross_housing_costs, net_housing_costs
        # on disposable_income_summary
        # also sets rent_or_mortgage_bank via HousingCostsCalculator
        Collators::HousingCostsCollator.call(disposable_income_summary:,
                                             gross_income_summary:,
                                             person:,
                                             submission_date:,
                                             allow_negative_net:)
        # sets legal_aid_bank on disposable_income_summary
        Collators::LegalAidCollator.call(disposable_income_summary)
      end
    end
  end
end
