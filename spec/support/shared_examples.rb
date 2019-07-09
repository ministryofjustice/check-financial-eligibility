RSpec.shared_examples 'it fails with message' do |message|
  it 'returns unprocessable entity' do
    expect(response).to have_http_status(422)
  end

  it 'returns a response with the specified message' do
    expect(parsed_response[:success]).to be false
    message.is_a?(Regexp) ? expect_message_match(message) : expect_message_equal(message)
    expect(parsed_response[:object]).to be_nil
  end

  def expect_message_match(message)
    expect(parsed_response[:errors].first).to match message
  end

  def expect_message_equal(message)
    expect(parsed_response[:errors].first).to eq message
  end
end
