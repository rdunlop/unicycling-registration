class RemoveJudgeFromTimeResult < ActiveRecord::Migration[4.2]
  def up
    remove_column :time_results, :judge_id
  end

  def down
    add_column :time_results, :judge_id, :integer
  end
end
