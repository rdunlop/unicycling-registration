class MakeBibNumberUniqueAndRequired < ActiveRecord::Migration[5.0]
  def change
    change_column_null :registrants, :bib_number, false
    add_index :registrants, :bib_number, unique: true
  end
end
