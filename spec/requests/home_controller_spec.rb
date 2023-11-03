require 'rails_helper'

RSpec.describe "HomeControllers", type: :request do
  describe 'GET #index' do
    it 'returns a successful response' do
      get '/home'
      expect(response).to have_http_status(200)
    end
  end
end
