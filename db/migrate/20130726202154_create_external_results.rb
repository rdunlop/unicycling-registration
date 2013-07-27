class CreateExternalResults < ActiveRecord::Migration
  def change
    create_table :external_results do |t|
      t.integer :competitor_id
      t.string :details
      t.integer :rank

      t.timestamps
    end
  end
end
