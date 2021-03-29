require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  class TestController < ::ApplicationController
    def show
      if params[:raise_error]
        35 / 0
      elsif params[:param_error]
        raise Apipie::ParamError, 'The param error message'
      else
        render_success
      end
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  before do
    Rails.application.routes.draw do
      get '/my_test', to: 'test#show'
    end
  end
  after do
    Rails.application.reload_routes!
  end

  context 'no error raised' do
    it 'returns json success response' do
      expected_response = {
        success: true,
        errors: []
      }.to_json
      get '/my_test'
      expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
    end
  end

  context 'raising an error' do
    it 'returns standard error response' do
      expected_response = {
        success: false,
        errors: ['ZeroDivisionError: divided by 0']
      }.to_json
      get '/my_test?raise_error=1'
      expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
    end

    it 'is captured by Sentry' do
      expect(Sentry).to receive(:capture_exception).with(instance_of(ZeroDivisionError))
      get '/my_test?raise_error=1'
    end

    context 'Apipie::ParamError' do
      it 'returns standard error response' do
        expected_response = {
          success: false,
          errors: ['The param error message']
        }.to_json
        get '/my_test?param_error=1'
        expect(parsed_response).to eq JSON.parse(expected_response, symbolize_names: true)
      end

      it 'is a captured message by Sentry' do
        expect(Sentry).to receive(:capture_exception).with(instance_of(Apipie::ParamError))
        get '/my_test?param_error=1'
      end
    end
  end
end
