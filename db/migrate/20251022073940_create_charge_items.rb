class CreateChargeItems < ActiveRecord::Migration[8.1]
  def change
    create_table :charge_items do |t|
      t.string :name
      t.references :charge_category, null: false, foreign_key: true
      t.string :unit
      t.integer :default_price_cents
      t.integer :position
      t.boolean :active, default: true
      t.jsonb :metadata, default: {}
      t.integer :inventory_item_id

      t.timestamps
    end
    add_index :charge_items, [:charge_category_id, :position]
  end
end
