class Assessment < ApplicationRecord
  extend EnumHash

  serialize :remarks

  validates :remote_ip,
            :submission_date,
            :matter_proceeding_type, presence: true

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

  attr_accessor :version

  # Always instantiate a new Remarks object from a nil value
  def remarks
    attributes['remarks'] || Remarks.new(id)
  rescue StandardError
    Remarks.new(id)
  end
end
