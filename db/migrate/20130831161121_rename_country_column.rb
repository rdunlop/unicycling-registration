class RenameCountryColumn < ActiveRecord::Migration
  def change
    rename_column :registrants, :country, :country_residence
  end
end
