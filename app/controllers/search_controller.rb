class SearchController < ApplicationController
  before_action :authenticate_user!
  MAX_THREADS = 5

  def index
    @results = if params[:file].present?
        perform_search_from_csv(params[:file])
      elsif params[:product_id].present?
        search_api(params[:product_id], params[:gl])
      else
        []
      end
  end

  private

  def perform_search_from_csv(file)
    require 'csv'
    queue = Queue.new

    CSV.foreach(file.path, headers: true, col_sep: ';') { |row| queue << row }

    workers = Array.new(MAX_THREADS) do
      Thread.new do
        begin
          until queue.empty?
            row = queue.pop(true)
            search_api(row['Product ID'], row['Gl'])
          end
        rescue ThreadError
          # Handle empty queue exception
        end
      end
    end

    workers.each(&:join)
    @results = workers.flat_map(&:value)
  end

  def search_api(product_id, gl)
    uri = URI("https://www.searchapi.io/api/v1/search")
    params = {
      engine: "google_product_offers",
      product_id: product_id,
      gl: gl,
      api_key: ENV['SEARCHAPI_KEY'],
      sort_by: "total_price",
      durability: "new"
    }
    uri.query = URI.encode_www_form(params)

    response = fetch_data(uri)
    process_response(response) if response.is_a?(Net::HTTPSuccess)
  end

  def fetch_data(uri)
    Net::HTTP.get_response(uri)
  rescue StandardError => e
    Rails.logger.error("Failed to fetch data: #{e.message}")
    nil
  end

  def process_response(response)
    parsed_response = JSON.parse(response.body)
    product_info = parsed_response["product"]
    offers = parsed_response["offers"]

    offers&.map do |result|
      current_user.search_results.create!(
        product_id: product_info["product_id"],
        title: product_info["title"],
        gl: parsed_response["search_parameters"]["gl"],
        total_price: result["total_price"],
        extracted_total_price: result["extracted_total_price"],
        date: Time.zone.today
      )
    end
  end
end
