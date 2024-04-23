class UpdateSearchResultsSchema < ActiveRecord::Migration[7.1]
  def change
    remove_column :search_results, :query, :string
    remove_column :search_results, :location, :string
    remove_column :search_results, :price, :string
    remove_column :search_results, :link, :string
    remove_column :search_results, :thumbnail, :string

    rename_column :search_results, :extracted_price, :extracted_total_price

    add_column :search_results, :gl, :string
    add_column :search_results, :date, :date
  end
end
