class CreateEventClassModel < ActiveRecord::Migration
  def change
    create_table :event_classes do |t|
      t.string :name
      t.timestamps
    end
  end
end
