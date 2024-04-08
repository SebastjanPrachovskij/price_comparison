class CreateSearchResults < ActiveRecord::Migration[7.1]
  def change
    create_table :search_results do |t|
      t.references :user, null: false, foreign_key: true
      t.string :query
      t.string :location
      t.string :product_id
      t.string :title
      t.string :price
      t.float :extracted_price
      t.string :link
      t.string :thumbnail

      t.timestamps
    end
  end
end
