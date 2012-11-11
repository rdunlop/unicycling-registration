class CreateRegistrants < ActiveRecord::Migration
  def change
    create_table :registrants do |t|
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.date :birthday
      t.string :gender
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code
      t.string :phone
      t.string :mobile
      t.string :email

      t.timestamps
    end
  end
end
