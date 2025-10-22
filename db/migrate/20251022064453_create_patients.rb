class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :gender
      t.string :email
      t.string :phone_number
      t.text :address
      t.string :city

      t.timestamps
    end
  end
end
