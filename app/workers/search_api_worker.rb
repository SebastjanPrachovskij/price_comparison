class SearchApiWorker
  include Sidekiq::Worker

  def perform(product_gl_pairs)
    product_gl_pairs.each do |pair|
      product_id = pair['Product ID']
      gl = pair['Gl']
      search_api(product_id, gl)
    end
  end

  private

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

      SearchResult.create!(
        product_id: product_info["product_id"],
        title: product_info["title"],
        link: result["link"],
        gl: parsed_response["search_parameters"]["gl"],
        total_price: result["total_price"],
        extracted_total_price: result["extracted_total_price"],
        json_data: result,
        date: Time.zone.today
      )
    end
  end
end
