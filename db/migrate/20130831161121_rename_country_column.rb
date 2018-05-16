class RenameCountryColumn < ActiveRecord::Migration[4.2]
  def change
    rename_column :registrants, :country, :country_residence
  end
end
