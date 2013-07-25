class CreateAwardLabels < ActiveRecord::Migration
  def change
    create_table :award_labels do |t|
      t.integer :bib_number
      t.string :first_name
      t.string :last_name
      t.string :partner_first_name
      t.string :partner_last_name
      t.string :competition_name
      t.string :team_name
      t.string :age_group
      t.string :gender
      t.string :details
      t.integer :place
      t.integer :user_id
      t.integer :registrant_id

      t.timestamps
    end
  end
end
