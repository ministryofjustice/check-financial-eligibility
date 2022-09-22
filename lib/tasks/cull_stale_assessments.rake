namespace :stale_assessments do
  desc "batch job to delete all assessments and associated records older than two weeks"
  task cull: :environment do
    CullStaleAssessmentsService.call
  end
end
