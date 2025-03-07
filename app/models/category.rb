class Category < ApplicationRecord
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  has_many :transactions
  belongs_to :parent, class_name: "Category", optional: true
end
