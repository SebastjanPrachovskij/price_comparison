class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:search_history]

  def index
  end

  def terms
  end

  def privacy
  end

  def search_history
    @unique_products = current_user.search_results.select('distinct on (product_id, gl) product_id, gl, title').order(:product_id, :gl)
  end

  def product_graph
    @result = SearchResult.find(params[:id])
    # Assuming you will have date and other necessary data in @result to plot the graph
  end

  def product_details
    @product_id = params[:product_id]
    @gl = params[:gl]
    @filter_date = params[:filter_date]
    results_scope = current_user.search_results.where(product_id: @product_id, gl: @gl)

    if @filter_date.present?
      @filter_date = Date.parse(@filter_date)
      results_scope = results_scope.where(date: @filter_date)

      # Assuming all prices are in the same currency and the symbol is the first character
      extracted_total_prices = results_scope.pluck(:extracted_total_price)
      # Extract the numeric part and convert to decimal for accurate calculations
      @average_price = (extracted_total_prices.sum / extracted_total_prices.size).round(2) unless extracted_total_prices.empty?
    end

    @search_results = results_scope.order(date: :desc)

    @chart_data = results_scope.group_by_day(:date).average(:extracted_total_price).map do |date, price|
      [date.strftime("%Y-%m-%d"), price]
    end.to_h
  end
end
