class BaseAssessmentFixture
  def self.json
    ruby_hash.to_json
  end

  def self.pretty_json
    JSON.pretty_generate(ruby_hash)
  end

  def ruby_hash
    # define this in the derived class
  end
end
