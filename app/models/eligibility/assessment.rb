module Eligibility
  class Assessment < Base
    belongs_to :assessment, inverse_of: :eligibilities, foreign_key: :parent_id, class_name: '::Assessment'
  end
end
