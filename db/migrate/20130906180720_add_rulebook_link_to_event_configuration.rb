class AddRulebookLinkToEventConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :rulebook_url, :string
  end
end
