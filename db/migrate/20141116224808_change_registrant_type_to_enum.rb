class ChangeRegistrantTypeToEnum < ActiveRecord::Migration
  def up
    add_column :registrants, :registrant_type, :string, default: 'competitor'
    execute "UPDATE registrants SET registrant_type = 'noncompetitor' where competitor = false"
    remove_column :registrants, :competitor

    add_index :registrants, :registrant_type
  end

  def down
    remove_index :registrants, :registrant_type
    add_column :registrants, :competitor, :boolean
    execute "UPDATE registrants SET competitor = true WHERE registrant_type = 'competitor'"
    execute "UPDATE registrants SET competitor = false WHERE registrant_type != 'competitor'"
    remove_column :registrants, :registrant_type
  end
end
