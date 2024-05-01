class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def show
    @product_id = params[:product_id]
    start_date = params[:start_date].presence ? Date.parse(params[:start_date]) : (Date.today - 30.days)
    end_date = params[:end_date].presence ? Date.parse(params[:end_date]) : Date.today

    @comparisons = current_user.search_results.where(product_id: @product_id, date: start_date..end_date)
                               .group('date', 'gl')
                               .order('date DESC, gl')
                               .pluck('date', 'gl', 'AVG(converted_total_price)', 'AVG(extracted_total_price)')

    # Apply conversion rate manually
    @comparisons = @comparisons.map do |date, gl, converted_avg, extracted_avg|
      average_price = converted_avg || (extracted_avg * conversion_rate(gl))
      { date: date, gl: gl, average_price: average_price }
    end
  end

  private

  # Returns the conversion rate based on 'gl'
  def conversion_rate(gl)
    rates = {
      'US' => 0.94,
      'GB' => 1.17,
      'PL' => 0.23
    }
    rates[gl.upcase] || 1.0  # default to 1.0 if no specific rate is found
  end
end
