class AddMusicToRegistrantChoices < ActiveRecord::Migration[4.2]
  def change
    add_column :registrant_choices, :music, :string
  end
end
