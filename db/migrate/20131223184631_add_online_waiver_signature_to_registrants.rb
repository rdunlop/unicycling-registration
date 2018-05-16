class AddOnlineWaiverSignatureToRegistrants < ActiveRecord::Migration[4.2]
  def change
    add_column :registrants, :online_waiver_signature, :string
  end
end
