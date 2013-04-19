class CreateJudgeType < ActiveRecord::Migration
  def change
    create_table :judge_types do |t|
      t.string :name
      t.string :val_1_description
      t.string :val_2_description
      t.string :val_3_description
      t.string :val_4_description
      t.integer :val_1_max
      t.integer :val_2_max
      t.integer :val_3_max
      t.integer :val_4_max
      t.integer :event_class_id

      t.timestamps
    end
  end
end
