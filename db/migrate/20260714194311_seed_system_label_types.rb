class SeedSystemLabelTypes < ActiveRecord::Migration[8.1]
  def up
    Apartment::Tenant.switch("public") do
      SystemLabelType.seed_defaults!
    end
  end

  def down
    Apartment::Tenant.switch("public") do
      SystemLabelType.where(name: SystemLabelType::DEFAULTS.keys).destroy_all
    end
  end
end
