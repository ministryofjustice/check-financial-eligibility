class Assessment < ApplicationRecord
  extend EnumHash

  serialize :remarks

  validates :remote_ip,
            :submission_date,
            presence: true
  validates :version, inclusion: { in: CFEConstants::VALID_ASSESSMENT_VERSIONS, message: "not valid in Accept header" }

  has_one :applicant, dependent: :destroy
  has_one :capital_summary, dependent: :destroy, class_name: "ApplicantCapitalSummary"
  has_one :gross_income_summary, dependent: :destroy, class_name: "ApplicantGrossIncomeSummary"
  has_one :disposable_income_summary, dependent: :destroy, class_name: "ApplicantDisposableIncomeSummary"

  has_one :partner, dependent: :destroy
  has_one :partner_capital_summary, dependent: :destroy
  has_one :partner_gross_income_summary, dependent: :destroy
  has_one :partner_disposable_income_summary, dependent: :destroy

  has_many :dependants, dependent: :destroy, class_name: "ApplicantDependant"
  has_many :partner_dependants, dependent: :destroy, class_name: "PartnerDependant"
  has_many :properties, through: :capital_summary, dependent: :destroy
  has_many :vehicles, through: :capital_summary, dependent: :destroy
  has_many :capital_items, through: :capital_summary, dependent: :destroy
  has_many :assessment_errors, dependent: :destroy
  has_many :explicit_remarks, dependent: :destroy
  has_many :employments, dependent: :destroy, class_name: "ApplicantEmployment"
  has_many :partner_employments, dependent: :destroy
  has_many :eligibilities,
           class_name: "Eligibility::Assessment",
           foreign_key: :parent_id,
           inverse_of: :assessment,
           dependent: :destroy
  has_many :employment_payments, through: :employments
  has_many :proceeding_types,
           dependent: :destroy
  has_many :request_logs, dependent: :destroy

  delegate :determine_result!, to: :capital_summary
  delegate :cash_transaction_categories, to: :gross_income_summary

  enum :level_of_representation, { certificated: 0, controlled: 1 }

  # Always instantiate a new Remarks object from a nil value
  def remarks
    attributes["remarks"] || Remarks.new(id)
  rescue StandardError
    Remarks.new(id)
  end

  def proceeding_type_codes
    proceeding_types.order(:ccms_code).map(&:ccms_code)
  end
end
