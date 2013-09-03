class AddCountryRepresenting < ActiveRecord::Migration
  def change
    add_column :registrants, :country_representing, :string
  end
end
