class RemoveExternalIdFromCompetitor < ActiveRecord::Migration[4.2]
  def change
    remove_column :competitors, :custom_external_id, :integer
  end
end
