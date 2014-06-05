class RemoveExternalIdFromCompetitor < ActiveRecord::Migration
  def change
    remove_column :competitors, :custom_external_id, :integer
  end
end
