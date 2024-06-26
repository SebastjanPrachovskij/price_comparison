class SearchResult < ApplicationRecord
  belongs_to :user

  validates :product_id, presence: true
  validates :title, presence: true
  validates :link, presence: true
  validates :json_data, presence: true
  validates :gl, presence: true
  validates :total_price, presence: true
  validates :extracted_total_price, presence: true, numericality: true
  validates :converted_total_price, presence: true, numericality: true
  validates :date, presence: true
end
