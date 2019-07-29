class Result < ActiveRecord::Base
  after_initialize do
    self.details = {} if details.nil?
  end
end
