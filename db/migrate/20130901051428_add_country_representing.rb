class AddCountryRepresenting < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :country_representing, :string
  end
end
