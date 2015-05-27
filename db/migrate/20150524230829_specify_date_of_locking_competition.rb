class SpecifyDateOfLockingCompetition < ActiveRecord::Migration
  def up
    add_column :competitions, :locked_at, :datetime
    add_column :competitions, :published_at, :datetime

    execute "UPDATE competitions SET locked_at = updated_at WHERE locked = true"
    execute "UPDATE competitions SET published_at = updated_at WHERE published = true"

    remove_column :competitions, :locked
    remove_column :competitions, :published
  end

  def down
    add_column :competitions, :locked, :boolean, defailt: false, null: false
    add_column :competitions, :published, :boolean, default: false, null: false

    execute "UPDATE competitions SET locked = true WHERE locked_at IS NOT NULL"
    execute "UPDATE competitions SET published = true WHERE published_at IS NOT NULL"

    remove_column :competitions, :locked_at
    remove_column :competitions, :published_at
  end
end
