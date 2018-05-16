class StoreLogoOnS3 < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :logo_file, :string
  end
end
