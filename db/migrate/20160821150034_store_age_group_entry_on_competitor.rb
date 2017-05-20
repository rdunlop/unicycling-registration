class StoreAgeGroupEntryOnCompetitor < ActiveRecord::Migration
  def change
    add_column :competitors, :age_group_entry_id, :integer
    add_index :competitors, %i[competition_id age_group_entry_id]
  end
end
