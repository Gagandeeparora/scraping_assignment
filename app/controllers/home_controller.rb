class HomeController < ApplicationController

	def index
		@page = (search_params[:page].to_i > 0) ? search_params[:page].to_i : 1
		if search_params[:search_keyword]
			@results = GithubScraper.call(search_params[:search_keyword], @page)
			@total_pages = @results[:page_count].to_i || 1
			if @results && @results[:error]
				flash[:error] = @results[:error]
			end
		end
	end

	private
    def search_params
      params.permit(:search_keyword, :page)
    end
end
