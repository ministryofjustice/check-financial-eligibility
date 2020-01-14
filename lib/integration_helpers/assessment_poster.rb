class AssessmentPoster
  include ActionDispatch::Integration::Runner
  def initialize(rows)
    @rows = rows
  end

  def run
    PayloadGenerator.new(@rows).run
  end

  def headers
    {
      'CONTENT_TYPE' => 'application/json',
      'Accept' => 'application/json;version=2'
    }
  end
end
