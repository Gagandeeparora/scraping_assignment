require 'open-uri'
class GithubScraper < ApplicationService
	attr_reader :url

	def initialize(request_params,page_number=1)
    @url = "https://github.com/search?q=#{request_params}&type=repositories&p=#{page_number}"
  end

  def call
    get_scraped_data
  end


  private
	  def get_scraped_data
	  	# return {success: true, url: @urls}
	  	retries = 0
	  	begin
	  		response = URI.open(@url)
      	parse_response = JSON.parse(response.read)
		    repositories = parse_response['payload']['results'].map { |repo| repo.slice('id', 'hl_name', 'language') }
		    result_count = parse_response['payload']['result_count']
		    page_count = parse_response['payload']['page_count']
		    {success: true, repositories_result: repositories, result_count: result_count, page_count: result_count}
	  	rescue OpenURI::HTTPError => e
	  		if (retries += 1) < 2
	  			Rails.logger.debug "429 occured"
	  			sleep(1.minutes)
	  			retry
	  		end
	  		{error: 'Too Many Request. Please try after 5 mins'}
	  	rescue Exception => e
	  		Rails.logger.debug "Error :: #{e.inspect}"
	  		{error: "Error Occured"}
	  	end
	  end

end

