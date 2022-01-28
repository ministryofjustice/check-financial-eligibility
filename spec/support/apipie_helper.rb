ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __dir__)
require 'apipie-rails'

module ApipieRecorderPatch
  def record
    super.try(:merge, title: RSpec.current_example.metadata[:doc_title] || 'Default')
  end
end

class Apipie::Extractor::Recorder
  prepend ApipieRecorderPatch
end
