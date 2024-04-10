class SearchController < ApplicationController
  before_action :authenticate_user!
  MAX_THREADS = 5

  def index
    if params[:file].present?
      perform_search_from_csv(params[:file])
    elsif params[:query].present?
      @results = search_api(params[:query], params[:location])
    else
      # Handle the case where the search parameters are empty
      @results = []
    end
  end

  private

  def perform_search_from_csv(file)
    require 'csv'
    queue = Queue.new
  
    CSV.foreach(file.path, headers: true, col_sep: ';') do |row|
      queue << row
    end
  
    workers = Array.new(MAX_THREADS) do
      Thread.new do
        until queue.empty?
          row = queue.pop(true) rescue nil
          next unless row
  
          query = row['Query']
          location = row['Location']
          gl = row['Gl']
          hl = row['Hl']
          domain = row['Domain']
          search_api(query, location, gl, hl, domain)
        end
      end
    end
  
    workers.each(&:join)
    @results = workers.map(&:value).flatten
  end
  

  def search_api(query, location, gl, hl, domain)
    require "net/http"
    require "uri"
    require "json"

    uri = URI.parse("https://www.searchapi.io/api/v1/search")
    params = {
      engine: "google_shopping",
      q: query,
      location: location,
      gl: gl,
      hl: hl,
      google_domain: domain,
      api_key: ENV['SEARCHAPI_KEY'],
      num: 8
    }.compact_blank

    uri.query = URI.encode_www_form(params)
    
    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      
      shopping_results = parsed_response["shopping_results"]

      shopping_results.map do |result|
        current_user.search_results.create!(
          {
            query: parsed_response.dig("search_parameters","q") || query,
            location: parsed_response.dig("search_parameters", "location_used") || location,
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
      { error: "There was an error with the SearchApi." }
    end
  end
end
