class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:query].present?
      @results = search_api(params[:query], params[:location])
    else
      # Handle the case where the search parameters are empty
      @results = []
    end
  end

  private

  def search_api(query, location)
    require "net/http"
    require "uri"
    require "json"

    uri = URI.parse("https://www.searchapi.io/api/v1/search")
    params = {
      engine: "google_shopping",
      q: query || "Iphone 15",
      location: location || "New York",
      api_key: ENV['SEARCHAPI_KEY'],
      num: 8
    }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      
      shopping_results = parsed_response["shopping_results"]

      shopping_results.map do |result|
        current_user.search_results.create(
          {
            query: query,
            location: location,
            product_id: result["product_id"],  
            title: result["title"],
            price: result["price"],
            extracted_price: result["extracted_price"],
            link: result["link"],
            thumbnail: result["thumbnail"]
          }
        )
      end
    else
      { error: "There was an error with the search API." }
    end
  end
end
