class AddMonthAndYearToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :month, :integer
    add_column :transactions, :year, :integer
  end
end
