class AddTogglesForFreestyleDismountJudging < ActiveRecord::Migration
  def change
    add_column :competitions, :enter_separated_dismount_scores, :boolean, null: false, default: false
    add_column :competitions, :dedicated_dismount_judges, :boolean, null: false, default: false
  end
end
