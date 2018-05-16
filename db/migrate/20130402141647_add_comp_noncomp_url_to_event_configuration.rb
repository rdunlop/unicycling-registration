class AddCompNoncompUrlToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :comp_noncomp_url, :string
  end
end
