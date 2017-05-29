class RegistrationCostUpdater
  # run by the scheduler in order to update the current RegistrationCost,
  def self.update_registration_periods
    Apartment.tenant_names.each do |tenant|
      Apartment::Tenant.switch(tenant) do
        new("competitor").update_current_period
        new("noncompetitor").update_current_period
      end
    end
  end

  attr_reader :registrant_type

  def initialize(registrant_type)
    @registrant_type = registrant_type
  end

  # Removes all unpaid reg-items for the old period, and creating ones for the new period
  def update_current_period(date = Date.today)
    now_period = RegistrationCost.relevant_period(registrant_type, date)

    old_period = RegistrationCost.for_type(registrant_type).current_period

    # update the last-run date, even if we aren't going to change periods
    Rails.cache.write("/registration_cost/#{registrant_type}/last_update_run_date", date)

    if now_period == old_period
      return false
    end

    Notifications.updated_current_reg_period(old_period.try(:name), now_period.try(:name)).deliver_later

    missing_regs = []

    unless now_period.nil?
      Registrant.where(registrant_type: registrant_type).all.find_each do |reg|
        new_item = now_period.expense_item_for(reg)

        next if new_item.nil?

        unless reg.set_registration_item_expense(new_item, false)
          missing_regs << reg.bib_number
        end
      end
    end

    if missing_regs.any?
      Notifications.missing_old_reg_items(missing_regs).deliver_later
    end

    old_period&.update_attribute(:current_period, false)
    now_period&.update_attribute(:current_period, true)

    true
  end

  def self.update_checked_recently?(date = Date.today)
    update_type_recently?("competitor", date) || update_type_recently?("noncompetitor", date)
  end

  def self.update_type_recently?(registrant_type, date)
    last_update_date = Rails.cache.fetch("/registration_cost/#{registrant_type}/last_update_run_date")
    return false if last_update_date.nil?

    last_update_date + 2.days >= date
  end
end
