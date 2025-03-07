class RemoveCategoryFromTransactions < ActiveRecord::Migration[8.0]
  def change
    remove_column :transactions, :category, :string
  end
end
