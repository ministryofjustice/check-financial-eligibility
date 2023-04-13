class ProceedingType < ApplicationRecord
  belongs_to :assessment

  validates :client_involvement_type, inclusion: { in: CFEConstants::VALID_CLIENT_INVOLVEMENT_TYPES, message: "invalid client_involvement_type: %{value}" }
  validate :proceeding_type_code_validations

  validates :ccms_code, uniqueness: { scope: :assessment_id }

private

  def proceeding_type_code_validations
    errors.add(:ccms_code, "invalid ccms_code: #{ccms_code}") unless ccms_code.to_sym.in?(CFEConstants::VALID_PROCEEDING_TYPE_CCMS_CODES)
  end
end
