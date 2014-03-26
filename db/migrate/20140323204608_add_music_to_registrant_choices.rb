class AddMusicToRegistrantChoices < ActiveRecord::Migration
  def change
    add_column :registrant_choices, :music, :string
  end
end
