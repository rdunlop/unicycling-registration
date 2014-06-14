class StoreLogoOnS3 < ActiveRecord::Migration
  def change
    add_column :event_configurations, :logo_file, :string
  end
end
