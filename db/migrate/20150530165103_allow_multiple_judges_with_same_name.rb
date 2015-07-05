class AllowMultipleJudgesWithSameName < ActiveRecord::Migration
  def up
    remove_index :judge_types, :name
    add_index :judge_types, [:name, :event_class], unique: true
  end

  def down
    remove_index :judge_types, [:name, :event_class]
    add_index :judge_types, :name, unique: true
  end
end
