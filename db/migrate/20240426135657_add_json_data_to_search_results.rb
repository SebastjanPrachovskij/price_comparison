class AddJsonDataToSearchResults < ActiveRecord::Migration[7.1]
  def change
    add_column :search_results, :json_data, :jsonb
    add_column :search_results, :link, :string
  end
end
