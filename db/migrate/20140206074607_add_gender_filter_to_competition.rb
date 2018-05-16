class AddGenderFilterToCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :gender_filter, :string
  end
end
