class CreateWallets < ActiveRecord::Migration[7.1]
  def change
    create_table :wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :role

      t.timestamps
    end
  end
end
