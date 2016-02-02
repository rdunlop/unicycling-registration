class TranslateEventAndEventCategoryNames < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    translates :name
  end

  class EventCategory < ActiveRecord::Base
    translates :name
  end

  def up
    Event.create_translation_table!({name: :string}, {migrate_data: true})
    EventCategory.create_translation_table!({name: :string}, {migrate_data: true})
  end

  def down
    Event.drop_translation_table!(migrate_data: true)
    EventCategory.drop_translation_table!(migrate_data: true)
  end
end
