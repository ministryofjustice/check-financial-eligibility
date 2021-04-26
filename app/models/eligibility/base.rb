module Eligibility
  class Base < ApplicationRecord
    self.table_name = :eligibilities

    validates :assessment_result, inclusion: { in: %w[pending eligible ineligible contribution_required] }

    validate :proceeding_type_code_validation

    private

    def proceeding_type_code_validation
      errors.add(:proceeding_type_code, "invalid: #{proceeding_type_code}") unless valid_proceeding_type_code?
    end

    def valid_proceeding_type_code?
      proceeding_type_code.to_sym.in?(ProceedingTypeThreshold.valid_ccms_codes)
    end
  end
end
