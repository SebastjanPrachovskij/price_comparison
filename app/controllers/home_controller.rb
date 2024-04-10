class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:search_history]

  def index
  end

  def terms
  end

  def privacy
  end

  def search_history
    sort_column = params[:sort] || 'created_at'
    sort_order = params[:order] == 'asc' ? 'asc' : 'desc'
    @results = current_user.search_results.order("#{sort_column} #{sort_order}")
  end
end
