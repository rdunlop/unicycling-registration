class AddAcmFieldsToTenantAliases < ActiveRecord::Migration[8.1]
  def change
    add_column :tenant_aliases, :acm_certificate_arn, :string
    add_column :tenant_aliases, :acm_dns_validation_cname_name, :string
    add_column :tenant_aliases, :acm_dns_validation_cname_value, :string
    add_column :tenant_aliases, :acm_cert_status, :string
  end
end
