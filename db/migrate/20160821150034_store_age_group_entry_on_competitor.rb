class StoreAgeGroupEntryOnCompetitor < ActiveRecord::Migration[4.2]
  def change
    add_column :competitors, :age_group_entry_id, :integer
    add_index :competitors, %i[competition_id age_group_entry_id]
  end
end
