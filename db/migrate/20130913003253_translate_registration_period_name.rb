class TranslateRegistrationPeriodName < ActiveRecord::Migration
  class RegistrationPeriod < ActiveRecord::Base
    translates :name
  end

  def up
    RegistrationPeriod.create_translation_table!({name: :string}, {migrate_data: true})
  end

  def down
    RegistrationPeriod.drop_translation_table!(migrate_data: true)
  end
end
