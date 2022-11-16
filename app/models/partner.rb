class Partner < ApplicationRecord
  belongs_to :assessment, optional: true
  validates :date_of_birth, cfe_date: { not_in_the_future: true }
end
