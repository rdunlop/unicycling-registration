class CreateRegistrantChoices < ActiveRecord::Migration
  def change
    create_table :registrant_choices do |t|
      t.integer :registrant_id
      t.integer :event_choice_id
      t.string :value

      t.timestamps
    end
  end
end
