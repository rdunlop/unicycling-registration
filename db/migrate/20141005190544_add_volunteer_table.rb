class AddVolunteerTable < ActiveRecord::Migration
  def change
    create_table :volunteer_opportunities do |t|
      t.string :description
      t.integer :display_order
      t.text :inform_emails
      t.timestamps
    end

    add_index :volunteer_opportunities, :display_order
    add_index :volunteer_opportunities, :description, unique: true

    create_table :volunteer_choices do |t|
      t.integer :registrant_id
      t.integer :volunteer_opportunity_id
      t.timestamps
    end

    add_index :volunteer_choices, %i[registrant_id volunteer_opportunity_id], unique: true, name: "volunteer_choices_reg_vol_opt_unique"
    add_index :volunteer_choices, [:registrant_id]
    add_index :volunteer_choices, [:volunteer_opportunity_id]
  end
end
