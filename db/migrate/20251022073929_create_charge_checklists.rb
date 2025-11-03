class CreateChargeChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :charge_checklists do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :issued, default: ''
      t.date :performed_on
      t.text :notes
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end
