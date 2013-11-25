class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.text :description
      t.text :site
      t.date :purchase_date
      t.string :status
      t.date :status_date
      t.text :notes

      t.timestamps
    end

    add_index :orders, :created_at
  end
end
