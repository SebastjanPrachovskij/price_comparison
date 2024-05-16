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

    if @chart_data.values.any?
      min_price = @chart_data.values&.compact_blank&.min
      max_price = @chart_data.values&.compact_blank&.max
      @min_chart_value = min_price * 0.95
      @max_chart_value = max_price * 1.05
    end
  end

  def forecast
    @product_id = params[:product_id]
    @gl = params[:gl]
    results_scope = current_user.search_results.where(product_id: @product_id, gl: @gl)
  
    historical_data = results_scope.group_by_day(:date).average(:extracted_total_price).map do |date, price|
      [date.strftime("%Y-%m-%d"), price]
    end.to_h

    @forecast = Prophet.forecast(historical_data, count: 24)
    forecast_data = @forecast.map { |date, price| [date, price] }.to_h

    # Collect actual prices and forecasted prices for error calculation
    actual_prices = historical_data.values.compact
    predicted_prices = forecast_data.values.take(actual_prices.size)

    # Call print_errors to output the error metrics
    print_errors(actual_prices, predicted_prices, 'Prophet', 'Prophet Error Metrics')

    combined_data = {
      historical: historical_data,
      forecast: forecast_data
    }

    all_prices = historical_data.values + forecast_data.values
    @min_chart_value = all_prices.compact_blank.min
    @max_chart_value = all_prices.compact_blank.max

    respond_to do |format|
      format.json { render json: combined_data.merge(min_chart_value: @min_chart_value, max_chart_value: @max_chart_value) }
    end
  end

  private

  def mean_squared_error(actual, predicted)
    sum = 0.0
    actual.zip(predicted).each do |a, p|
      sum += (a - p) ** 2
    end
    sum / actual.size
  end

  def mean_absolute_error(actual, predicted)
    sum = 0.0
    actual.zip(predicted).each do |a, p|
      sum += (a - p).abs
    end
    sum / actual.size
  end

  def print_errors(actual, predicted, model_name, label)
    if actual.size != predicted.size
      puts "Error: Inconsistent data lengths. Actual: #{actual.size}, Predictions: #{predicted.size}"
      return
    end

    puts label
    mse_value = mean_squared_error(actual, predicted)
    rmse_value = Math.sqrt(mse_value)
    mae_value = mean_absolute_error(actual, predicted)
    mape_value = actual.zip(predicted).map { |a, p| (a - p).abs / a.to_f }.sum / actual.size * 100

    puts "MSE: #{mse_value}"
    puts "SQRT(MSE): #{rmse_value}"
    puts "MAE: #{mae_value}"
    puts "RMSE: #{rmse_value}"
    puts "MAPE: #{mape_value}%"
  end
end
