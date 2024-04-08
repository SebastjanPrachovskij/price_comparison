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

  def search_api(query, location = "New York")
    require "net/http"
    require "uri"
    require "json"

    uri = URI.parse("https://www.searchapi.io/api/v1/search")
    params = {
      engine: "google_shopping",
      q: query,
      location: location,
      api_key: ENV['SEARCHAPI_KEY']
    }
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      { error: "There was an error with the search API." }
    end
  end
end
