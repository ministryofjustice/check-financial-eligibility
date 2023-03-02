class Partner < ApplicationRecord
  belongs_to :assessment, optional: true
  validates :date_of_birth, date: {
    before: proc { Time.zone.tomorrow }, message: :not_in_the_future
  }
end
