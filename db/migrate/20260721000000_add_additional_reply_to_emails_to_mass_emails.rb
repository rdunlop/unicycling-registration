class AddAdditionalReplyToEmailsToMassEmails < ActiveRecord::Migration[8.0]
  def change
    add_column :mass_emails, :additional_reply_to_emails, :string
  end
end
