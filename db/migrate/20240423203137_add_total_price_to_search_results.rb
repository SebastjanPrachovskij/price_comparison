class AddTotalPriceToSearchResults < ActiveRecord::Migration[7.1]
  def change
    add_column :search_results, :total_price, :string
  end
end
