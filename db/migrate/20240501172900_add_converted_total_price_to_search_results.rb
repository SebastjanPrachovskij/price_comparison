class AddConvertedTotalPriceToSearchResults < ActiveRecord::Migration[7.1]
  def change
    add_column :search_results, :converted_total_price, :float
  end
end
