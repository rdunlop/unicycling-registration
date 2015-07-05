class AddTranslationToEventConfiguration < ActiveRecord::Migration
  class EventConfiguration < ActiveRecord::Base
    translates :short_name, :long_name, :location, :dates_description
  end

  def up
    EventConfiguration.create_translation_table!({
                                                   short_name: :string,
                                                   long_name: :string,
                                                   location: :string,
                                                   dates_description: :string
                                                 },                                                    {migrate_data: true})
  end

  def down
    EventConfiguration.drop_translation_table!(migrate_data: true)
  end
end
