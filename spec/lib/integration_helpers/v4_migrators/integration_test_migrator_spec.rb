require 'rails_helper'
require Rails.root.join('lib/v4_migrators/integration_test_migrator')

RSpec.describe IntegrationTestMigrator do
  let(:migrator) { described_class.new }
  
  describe '#run' do
    it 'prints info' do
      migrator.run
    end
  end
end
