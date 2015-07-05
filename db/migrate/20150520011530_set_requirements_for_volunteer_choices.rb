class SetRequirementsForVolunteerChoices < ActiveRecord::Migration
  def change
    change_column_null :volunteer_choices, :registrant_id, false
    change_column_null :volunteer_choices, :volunteer_opportunity_id, false

    change_column_null :volunteer_opportunities, :description, false
  end
end
