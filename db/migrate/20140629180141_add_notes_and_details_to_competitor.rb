class AddNotesAndDetailsToCompetitor < ActiveRecord::Migration
  def change
    add_column :competitors, :geared, :boolean, default: false
    add_column :competitors, :wheel_size, :integer
    add_column :competitors, :notes, :string
  end
end
