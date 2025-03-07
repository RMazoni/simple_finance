class RemoveDateFromTransactions < ActiveRecord::Migration[8.0]
  def change
    remove_column :transactions, :date, :date
  end
end
