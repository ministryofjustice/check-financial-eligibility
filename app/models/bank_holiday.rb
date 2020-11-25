class BankHoliday < ApplicationRecord
  serialize :dates, Array

  scope :by_updated_at, -> { order(updated_at: :asc) }

  validates :dates, presence: true

  def self.dates
    populate_dates if refresh_required?
    BankHoliday.first.dates
  end

  def self.refresh_required?
    BankHoliday.count.zero? || BankHoliday.first.updated_at < 10.days.ago
  end

  def self.populate_dates
    rec = BankHoliday.first || BankHoliday.new
    rec.dates = BankHolidayRetriever.dates
    rec.save!
  end
end
