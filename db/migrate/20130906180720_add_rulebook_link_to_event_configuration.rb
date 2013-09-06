class AddRulebookLinkToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :rulebook_url, :string
  end
end
