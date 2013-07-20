class RemoveJudgeFromTimeResult < ActiveRecord::Migration
  def up
    remove_column :time_results, :judge_id
  end

  def down
    add_column :time_results, :judge_id, :integer
  end
end
