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
    results_scope = current_user.search_results.where(product_id: @product_id, gl: @gl)
  
    if params[:start_date].present? && params[:end_date].present?
      @start_date = Date.parse(params[:start_date])
      @end_date = Date.parse(params[:end_date])
      results_scope = results_scope.where(date: @start_date..@end_date)
  
      extracted_total_prices = results_scope.pluck(:extracted_total_price)
      @average_price = extracted_total_prices.sum / extracted_total_prices.size unless extracted_total_prices.empty?
    end
  
    @search_results = results_scope.order(date: :desc)
    @chart_data = results_scope.group_by_day(:date).average(:extracted_total_price).map do |date, price|
      [date.strftime("%Y-%m-%d"), price]
    end.to_h
  end
  
end
