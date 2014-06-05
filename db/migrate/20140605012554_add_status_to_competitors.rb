class AddStatusToCompetitors < ActiveRecord::Migration
  def change
    add_column :competitors, :status, :integer, default: 0
  end
end
