class UpdateEventClass < ActiveRecord::Migration
  def up
    drop_table :event_classes
    remove_column :judge_types, :event_class_id
    add_column :judge_types, :event_class, :string
    add_column :events, :event_class, :string
  end

  def down
    create_table :event_classes do |t|
      t.string :name
      t.timestamps
    end
    add_column :judge_types, :event_class_id, :integer
    remove_column :judge_types, :event_class
    remove_column :events, :event_class
  end
end
