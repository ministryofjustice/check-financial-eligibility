class CullStaleAssessmentsService
  def self.call
    new.call
  end

  def call
    Assessment.destroy_by(created_at: ..CFEConstants::STALE_ASSESSMENT_THRESHOLD_DAYS.days.ago)
  end
end
