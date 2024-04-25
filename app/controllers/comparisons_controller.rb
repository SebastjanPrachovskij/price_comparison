class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  include ComparisonsHelper

  def show
    @product_id = params[:product_id]
    start_date = params[:start_date].presence ? Date.parse(params[:start_date]) : (Date.today - 30.days)
    end_date = params[:end_date].presence ? Date.parse(params[:end_date]) : Date.today

    @comparisons = SearchResult.where(product_id: @product_id).where(date: start_date..end_date).select('date, gl, AVG(extracted_total_price) as average_price').group('date, gl').order('date DESC, gl')
  end
end
