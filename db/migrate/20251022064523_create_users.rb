class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.references :role, null: false, foreign_key: true
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :gender
      t.string :status, default: 'Active'

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
