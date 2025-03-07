class Transaction < ApplicationRecord
  belongs_to :category, optional: true

  validates :description, :amount, :month, :year, presence: true
  validates :month, inclusion: { in: 1..12 }
  validates :year, numericality: { only_integer: true, greater_than: 2000 }
end
