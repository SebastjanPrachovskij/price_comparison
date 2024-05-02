class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:search_history]
  protect_from_forgery except: :forecast 

  def index
  end

  def terms
  end

  def privacy
  end

  def search_history
    @unique_products = current_user.search_results.select('distinct on (product_id, gl) product_id, gl, title').order(:product_id, :gl)
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

  def forecast
    @product_id = params[:product_id]
    @gl = params[:gl]
    results_scope = current_user.search_results.where(product_id: @product_id, gl: @gl).order(:date)
  
    historical_data = results_scope.pluck(:date, :extracted_total_price).map do |date, price|
      [date.strftime("%Y-%m-%d"), price]
    end.to_h

    @forecast = Prophet.forecast(historical_data, count: 10) # Assume this returns a hash
    forecast_data = @forecast.map { |date, price| [date, price] }.to_h

    combined_data = {
      historical: historical_data,
      forecast: forecast_data
    }
    # ==================================
    # start_date = Date.today - 365.days  # Start from one year ago
    # end_date = Date.today  # Until today
    
    # # Create a hash with random prices over the past year
    # series = (start_date..end_date).each_with_object({}) do |date, hash|
    #   random_price = rand(100.0..200.0).round(2)
    #   hash[date.strftime("%Y-%m-%d")] = random_price
    # end

    # @forecast = Prophet.forecast(series, count: 10)

    # forecast_series = @forecast.map { |date, price| [date.strftime("%Y-%m-%d"), price] }.to_h

    # combined_data = {
    #   historical: series,
    #   forecast: forecast_series
    # }
   # ==================================
    respond_to do |format|
      format.json { render json: combined_data }
    end
  end
end
