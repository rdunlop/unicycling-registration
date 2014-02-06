class AddGenderFilterToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :gender_filter, :string
  end
end
