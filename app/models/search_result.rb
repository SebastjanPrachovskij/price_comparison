class SearchResult < ApplicationRecord
  belongs_to :user

  validates :product_id, presence: true
  validates :title, presence: true
  validates :extracted_total_price, numericality: true
  validates :date, presence: true
end
