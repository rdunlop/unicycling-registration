class CreateCompetitorResultTable < ActiveRecord::Migration[4.2]
  def change
    create_table :results do |t|
      t.references :competitor
      t.string :result_type
      t.integer :result_subtype
      t.integer :place
      t.string :status
      t.timestamps
    end
  end
end
