class ReplaceRegisteredGenderWithPronouns < ActiveRecord::Migration[7.0]
  def up
    add_column :registrants, :pronouns, :string
    add_column :registrants, :other_pronoun, :string
    # In production, we don't have any 'Other' values yet, so we don't have to handle them
    execute "UPDATE registrants SET pronouns = 'She/her' WHERE registered_gender = 'Female'"
    execute "UPDATE registrants SET pronouns = 'He/him' WHERE registered_gender = 'Male'"
    remove_column :registrants, :registered_gender
  end

  def down
    add_column :registrants, :registered_gender, :string
    execute "UPDATE registrants SET registered_gender = 'Male' where pronouns = 'He/him'"
    execute "UPDATE registrants SET registered_gender = 'Female' where pronouns = 'She/her'"
    remove_column :registrants, :pronouns
    remove_column :registrants, :other_pronoun
  end
end
