class MakeExternalResultUniqueByCompetitor < ActiveRecord::Migration
  def change
    remove_index :external_results, :competitor_id
    add_index :external_results, :competitor_id, unique: true
  end
end
