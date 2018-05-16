class AddNumberOfMembersPerCompetitorToCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :num_members_per_competitor, :string
  end
end
