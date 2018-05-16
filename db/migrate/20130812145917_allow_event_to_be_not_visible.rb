class AllowEventToBeNotVisible < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :visible, :boolean
  end
end
