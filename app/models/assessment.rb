class Assessment < ApplicationRecord
  extend EnumHash

  serialize :remarks
  serialize :proceeding_type_codes, Array

  validates :remote_ip,
            :submission_date,
            presence: true
  validates :matter_proceeding_type, presence: true, if: :matter_proceeding_type_required?
  validates :proceeding_type_codes, presence: true, if: :proceeding_types_codes_required?
  validates :version, inclusion: { in: CFEConstants::VALID_ASSESSMENT_VERSIONS, message: 'not valid in Accept header' }

  validate :proceeding_type_codes_validations

  has_one :applicant, dependent: :destroy
  has_one :capital_summary, dependent: :destroy
  has_one :gross_income_summary, dependent: :destroy
  has_one :disposable_income_summary, dependent: :destroy

  has_many :dependants, dependent: :destroy
  has_many :properties, through: :capital_summary, dependent: :destroy
  has_many :vehicles, through: :capital_summary, dependent: :destroy
  has_many :capital_items, through: :capital_summary, dependent: :destroy
  has_many :assessment_errors, dependent: :destroy
  has_many :explicit_remarks, dependent: :destroy

  enum matter_proceeding_type: enum_hash_for(:domestic_abuse)

  delegate :determine_result!, to: :capital_summary
  delegate :cash_transaction_categories, to: :gross_income_summary

  # Always instantiate a new Remarks object from a nil value
  def remarks
    attributes['remarks'] || Remarks.new(id)
  rescue StandardError
    Remarks.new(id)
  end

  private

  def matter_proceeding_type_required?
    version == '3'
  end

  def proceeding_type_codes_validations
    return if version == '3'

    proceeding_type_codes.each do |code|
      errors.add(:proceeding_type_codes, "invalid: #{code}") unless code.to_sym.in?(ProceedingTypeThreshold.valid_ccms_codes)
    end
  end

  def proceeding_types_codes_required?
    version != '3'
  end
end
