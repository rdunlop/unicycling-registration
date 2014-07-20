class AddReadWriteToAdditionalRegistrantAccesses < ActiveRecord::Migration
  def change
    add_column :additional_registrant_accesses, :accepted_readwrite, :boolean, default: false
  end
end
