class FixFreeGroupLabel < ActiveRecord::Migration[5.1]
  def up
    execute "UPDATE expense_group_options SET option = 'One Free In Group' WHERE option = 'One Free in Group'"
  end

  def down
    execute "UPDATE expense_group_options SET option = 'One Free in Group' WHERE option = 'One Free In Group'"
  end
end
