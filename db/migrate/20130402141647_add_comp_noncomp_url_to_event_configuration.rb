class AddCompNoncompUrlToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :comp_noncomp_url, :string
  end
end
