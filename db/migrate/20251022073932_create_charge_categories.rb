class CreateChargeCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :charge_categories do |t|
      t.string :name
      t.string :key
      t.integer :position

      t.timestamps
    end
    add_index :charge_categories, :key, unique: true
  end
end
