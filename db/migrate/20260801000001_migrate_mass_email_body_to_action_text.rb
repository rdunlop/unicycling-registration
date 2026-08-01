class MigrateMassEmailBodyToActionText < ActiveRecord::Migration[7.0]
  def up
    MassEmail.find_each do |mass_email|
      old_body = mass_email.read_attribute(:body)
      next if old_body.blank?
      next if mass_email.body.present? # Already migrated to ActionText

      mass_email.body = old_body
      mass_email.save!
    end
  end

  def down
    ActionText::RichText.where(record_type: 'MassEmail', name: 'body').destroy_all
  end
end
