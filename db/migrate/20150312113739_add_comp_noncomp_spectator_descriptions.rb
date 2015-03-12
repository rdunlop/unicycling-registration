class AddCompNoncompSpectatorDescriptions < ActiveRecord::Migration
  def change
    add_column :event_configuration_translations, :competitor_benefits, :text
    add_column :event_configuration_translations, :noncompetitor_benefits, :text
    add_column :event_configuration_translations, :spectator_benefits, :text
  end
end
