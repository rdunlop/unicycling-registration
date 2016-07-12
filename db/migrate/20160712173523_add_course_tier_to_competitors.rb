class AddCourseTierToCompetitors < ActiveRecord::Migration
  def change
    add_column :competitors, :tier_number, :integer, default: 1, null: false
    add_column :competitors, :tier_description, :string
  end
end
