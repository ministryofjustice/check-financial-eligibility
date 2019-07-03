require 'rails_helper'

RSpec.describe UuidValidator do
  let(:params_description) { Faker::Commerce.product_name.underscore }

  subject { described_class.new(params_description) }

  it 'returns true with a uuid' do
    expect(subject.validate(SecureRandom.uuid)).to be_truthy
  end

  it 'returns false with an invalid uuid' do
    expect(subject.validate(SecureRandom.uuid[0..-4])).to be_falsey
  end
end
