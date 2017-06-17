class SplitRegistrationPeriodInTwo < ActiveRecord::Migration
  class RegistrationPeriod < ActiveRecord::Base
    translates :name
  end

  class RegistrationCost < ActiveRecord::Base
    translates :name
  end

  def up
    create_table :registration_costs do |t|
      t.date :start_date
      t.date :end_date
      t.integer :expense_item_id
      t.string :registrant_type, null: false
      t.boolean :onsite, default: false, null: false
      t.boolean :current_period, default: false, null: false
      t.timestamps null: false
    end

    add_index :registration_costs, [:current_period]
    add_index :registration_costs, %i[registrant_type current_period]

    create_table :registration_cost_translations do |t|
      t.integer :registration_cost_id, null: false
      t.string :locale, null: false
      t.string :name
      t.timestamps
    end

    add_index :registration_cost_translations, [:locale]
    add_index :registration_cost_translations, [:registration_cost_id]

    RegistrationCost.reset_column_information

    RegistrationPeriod.all.each do |rp|
      # Competitor
      rc = RegistrationCost.create!(
        start_date: rp.start_date,
        end_date: rp.end_date,
        created_at: rp.created_at,
        updated_at: rp.updated_at,
        onsite: rp.onsite,
        current_period: rp.current_period,
        registrant_type: "competitor",
        expense_item_id: rp.competitor_expense_item_id
      )
      rp.translations.each do |translation|
        rc.set_translations(translation.locale => { name: translation.name})
      end

      # NonCompetitor
      rc = RegistrationCost.create!(
        start_date: rp.start_date,
        end_date: rp.end_date,
        created_at: rp.created_at,
        updated_at: rp.updated_at,
        onsite: rp.onsite,
        current_period: rp.current_period,
        registrant_type: "noncompetitor",
        expense_item_id: rp.noncompetitor_expense_item_id
      )
      rp.translations.each do |translation|
        rc.set_translations(translation.locale => { name: translation.name})
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
