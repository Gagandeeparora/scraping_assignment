require 'rails_helper'
require 'open-uri'
require 'webmock/rspec'

RSpec.describe GithubScraper, type: :service do
  let(:request_params) { 'repo_scrapping' }
  let(:page_number) { 1 }

  describe '#call' do
    it 'scrapes data from GitHub repositories' do
      sample_response = {
        'payload' => {
          'results' => [
            { 'id' => 1, 'hl_name' => 'repo_scrapping', 'language' => 'Ruby' },
            { 'id' => 2, 'hl_name' => 'Repo 2', 'language' => 'JavaScript' }
          ],
          'result_count' => 2,
          'page_count' => 1
        }
      }

      stub_request(:get, "https://github.com/search?q=#{request_params}&type=repositories&p=#{page_number}")
        .to_return(status: 200, body: sample_response.to_json, headers: {})
      result = GithubScraper.call(request_params, page_number)
      expect(result[:success]).to eq(true)
      expect(result[:repositories_result].size).to eq(2)
      expect(WebMock).to have_requested(:get, "https://github.com/search?q=#{request_params}&type=repositories&p=#{page_number}")
    end

    it 'handles errors if too many requests' do
      stub_request(:get, "https://github.com/search?q=#{request_params}&type=repositories&p=#{page_number}")
        .to_return(status: 429, body: 'Too Many Requests', headers: {})
      result = GithubScraper.call(request_params, page_number)
      expect(result[:error]).to eq('Too Many Request. Please try after 5 mins')
    end

    
    it 'handles other errors' do
      stub_request(:get, "https://github.com/search?q=#{request_params}&type=repositories&p=#{page_number}")
        .to_raise("error")
      result = GithubScraper.call(request_params, page_number)
      expect(result[:error]).to eq('Error Occured')
    end
  end
end
