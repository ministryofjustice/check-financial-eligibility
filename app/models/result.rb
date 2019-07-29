class Result < ActiveRecord::Base
  belongs_to :assessment

  after_initialize do
    self.details = {} if details.nil?
  end
end
