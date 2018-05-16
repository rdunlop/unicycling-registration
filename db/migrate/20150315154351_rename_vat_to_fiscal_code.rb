class RenameVatToFiscalCode < ActiveRecord::Migration[4.2]
  def change
    rename_column :contact_details, :vat_number, :italian_fiscal_code
    rename_column :event_configurations, :vat_mode, :italian_requirements
  end
end
