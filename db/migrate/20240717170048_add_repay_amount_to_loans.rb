class AddRepayAmountToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :repay_amount, :decimal
  end
end
