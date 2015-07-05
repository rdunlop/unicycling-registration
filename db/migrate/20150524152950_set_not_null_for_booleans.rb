class SetNotNullForBooleans < ActiveRecord::Migration
  def change
    change_column_null :tenant_aliases, :verified, false, false

    change_column_default :registrant_event_sign_ups, :signed_up, false
    change_column_null :registrant_event_sign_ups, :signed_up, false, false

    change_column_default :competitions, :locked, false
    change_column_null :competitions, :locked, false, false

    change_column_default :contact_details, :emergency_attending, false
    change_column_null :contact_details, :emergency_attending, false, false
  end
end
