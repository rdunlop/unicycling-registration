class AddOnlineWaiverSignatureToRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :online_waiver_signature, :string
  end
end
