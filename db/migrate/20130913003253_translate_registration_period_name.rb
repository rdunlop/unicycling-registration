class TranslateRegistrationPeriodName < ActiveRecord::Migration
  def up
    RegistrationPeriod.create_translation_table!({
      :name => :string
    }, {
      :migrate_data => true
    })
  end

  def down
    RegistrationPeriod.drop_translation_table!({
      :migrate_data => true
    })
  end
end
