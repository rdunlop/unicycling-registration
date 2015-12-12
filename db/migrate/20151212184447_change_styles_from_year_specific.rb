class ChangeStylesFromYearSpecific < ActiveRecord::Migration
  def up
    execute "UPDATE event_configurations SET style_name='base_blue_pink' WHERE style_name='unicon_17'"
    execute "UPDATE event_configurations SET style_name='base_green_blue' WHERE style_name='naucc_2013'"
    execute "UPDATE event_configurations SET style_name='base_blue_purple' WHERE style_name='naucc_2014'"
    execute "UPDATE event_configurations SET style_name='base_purple_blue' WHERE style_name='naucc_2015'"
  end

  def down
    execute "UPDATE event_configurations SET style_name='unicon_17' WHERE style_name='base_blue_pink'"
    execute "UPDATE event_configurations SET style_name='naucc_2013' WHERE style_name='base_green_blue'"
    execute "UPDATE event_configurations SET style_name='naucc_2014' WHERE style_name='base_blue_purple'"
    execute "UPDATE event_configurations SET style_name='naucc_2015' WHERE style_name='base_purple_blue'"
  end
end
