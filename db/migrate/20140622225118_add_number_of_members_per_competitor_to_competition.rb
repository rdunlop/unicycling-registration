class AddNumberOfMembersPerCompetitorToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :num_members_per_competitor, :string
  end
end
