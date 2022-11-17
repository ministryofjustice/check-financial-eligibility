module Collators
  class OutgoingsCollator
    class << self
      def call(submission_date:, dependants:, person:, gross_income_summary:, disposable_income_summary:)
        collate_costs_and_allowances submission_date:, dependants:, person:, gross_income_summary:, disposable_income_summary:
      end

    private

      def collate_costs_and_allowances(submission_date:, dependants:, person:, gross_income_summary:, disposable_income_summary:)
        Collators::ChildcareCollator.call(submission_date:,
                                          dependants:,
                                          person:,
                                          gross_income_summary:,
                                          disposable_income_summary:)
        Collators::DependantsAllowanceCollator.call(dependants:,
                                                    disposable_income_summary:)
        Collators::MaintenanceCollator.call(disposable_income_summary)
        Collators::HousingCostsCollator.call(disposable_income_summary:,
                                             gross_income_summary:,
                                             dependants:,
                                             submission_date:)
        Collators::LegalAidCollator.call(disposable_income_summary)
      end
    end
  end
end
