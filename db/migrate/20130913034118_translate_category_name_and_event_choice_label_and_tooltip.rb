class TranslateCategoryNameAndEventChoiceLabelAndTooltip < ActiveRecord::Migration
  class Category < ActiveRecord::Base
    translates :name
  end

  class EventChoice < ActiveRecord::Base
    translates :label, :tooltip
  end

  def up
    Category.create_translation_table!({name: :string}, {migrate_data: true})
    EventChoice.create_translation_table!({label: :string, tooltip: :string}, {migrate_data: true})
  end

  def down
    Category.drop_translation_table!(migrate_data: true)
    EventChoice.drop_translation_table!(migrate_data: true)
  end
end
