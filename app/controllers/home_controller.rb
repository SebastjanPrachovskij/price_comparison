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

  def product_graph
    @result = SearchResult.find(params[:id])
    # Assuming you will have date and other necessary data in @result to plot the graph
  end
end
