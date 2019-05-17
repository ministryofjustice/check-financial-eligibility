class Assessment < ApplicationRecord
  validates :remote_ip, presence: true
  validates :request_payload, presence: true
end
