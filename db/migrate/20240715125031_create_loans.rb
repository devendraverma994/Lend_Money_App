class CreateLoans < ActiveRecord::Migration[7.1]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.decimal :amount
      t.string :state

      t.timestamps
    end
  end
end
