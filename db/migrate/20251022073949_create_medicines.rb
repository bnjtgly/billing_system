class CreateMedicines < ActiveRecord::Migration[8.1]
  def change
    create_table :medicines do |t|
      t.string :item_code
      t.string :drug_name
      t.string :generic_name
      t.string :frequency
      t.string :dosage
      t.string :route
      t.string :form
      t.string :strength
      t.string :unit
      t.integer :unit_price_cents, null: false, default: 0
      t.integer :qty
      t.text :notes
      t.jsonb :metadata, default: {}
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :medicines, :item_code, unique: true
  end
end
