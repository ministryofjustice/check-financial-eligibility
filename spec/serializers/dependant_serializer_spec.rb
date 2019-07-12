require 'rails_helper'

RSpec.describe DependantSerializer do
  let(:dependant) { create :dependant }

  it 'ouputs some json' do
    puts dependant.to_json
  end
end
