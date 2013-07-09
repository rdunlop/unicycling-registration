class CreateCompetitors < ActiveRecord::Migration
  def change
    create_table :competitors do |t|
      t.integer  :event_category_id
      t.integer  :position
      t.integer  :custom_external_id
      t.string   :custom_name
      t.timestamps
    end
  end
end
