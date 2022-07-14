module Eligibility
  class CrimeAssessment < CrimeBase
    belongs_to :assessment, foreign_key: :parent_id, class_name: "::Assessment"
  end
end
