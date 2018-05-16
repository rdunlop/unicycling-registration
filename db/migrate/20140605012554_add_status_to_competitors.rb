class AddStatusToCompetitors < ActiveRecord::Migration[4.2]
  def change
    add_column :competitors, :status, :integer, default: 0
  end
end
