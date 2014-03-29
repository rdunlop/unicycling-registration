class RegistrationPeriod < ActiveRecord::Base
  default_scope { order('start_date ASC') }

  validates :start_date, :end_date, :competitor_expense_item, :noncompetitor_expense_item, :presence => true

  translates :name
  accepts_nested_attributes_for :translations

  belongs_to :competitor_expense_item, :class_name => "ExpenseItem"
  belongs_to :noncompetitor_expense_item, :class_name => "ExpenseItem"

  validates :onsite, :inclusion => { :in => [true, false] } # because it's a boolean

  after_initialize :init

  after_save :clear_cache
  after_destroy :clear_cache

  def init
    self.onsite = false if self.onsite.nil?
  end

  def clear_cache
    Rails.cache.delete("/registration_period/by_date/#{Date.today}")
  end


  # We allow registrations to arrive 1 day _after_ the end date,
  # to account for timezone differences, and 'last minute' shoppers.
  def last_day
    self.end_date + 1.day
  end

  def current_period?(date = Date.today)
    return (self.start_date <= date and date <= last_day)
  end

  def past_period?(date = Date.today)
    return (self.last_day < date)
  end

  def self.last_online_period
    last_period = nil
    RegistrationPeriod.all.each do |rp|
      next if rp.onsite
      last_period = rp
    end
    last_period
  end

  def self.all_registration_expense_items
    RegistrationPeriod.all.collect{|rp| rp.competitor_expense_item} + RegistrationPeriod.all.collect{|rp| rp.noncompetitor_expense_item}
  end

  def self.relevant_period(date)
    rp_id = Rails.cache.fetch("/registration_period/by_date/#{date}")
    cached_rp = RegistrationPeriod.find_by_id(rp_id)
    return cached_rp unless cached_rp.nil?

    RegistrationPeriod.includes(:competitor_expense_item, :noncompetitor_expense_item).each do |rp|
      if rp.current_period?(date)
        Rails.cache.write("/registration_period/by_date/#{date}", rp.id, :expires_in => 5.minutes)
        return rp
      end
    end
    return nil
  end

  def self.paid_for_period(competitor, paid_items)
    RegistrationPeriod.includes(:noncompetitor_expense_item).includes(:competitor_expense_item).each do |rp|
      if competitor
        if paid_items.include?(rp.competitor_expense_item)
          return rp
        end
      else
        if paid_items.include?(rp.noncompetitor_expense_item)
          return rp
        end
      end
    end
    nil
  end


  def self.current_period
    where(:current_period => true).first
  end

  # run by the scheduler in order to update the current Registration_period,
  # Removes all unpaid reg-items for the old period, and creating ones for the new period
  def self.update_current_period(date = Date.today)
    now_period = relevant_period(date)

    old_period = current_period

    # update the last-run date, even if we aren't going to change periods
    Rails.cache.write("/registration_period/last_update_run_date", date)

    if (now_period == old_period)
      return false
    end

    Notifications.updated_current_reg_period(old_period, now_period).deliver

    old_comp_item = old_period.competitor_expense_item unless old_period.nil?
    old_noncomp_item = old_period.noncompetitor_expense_item unless old_period.nil?

    new_comp_item = now_period.competitor_expense_item unless now_period.nil?
    new_noncomp_item = now_period.noncompetitor_expense_item unless now_period.nil?

    all_reg_items = all_registration_expense_items
    missing_regs = []

    Registrant.all.each do |reg|
      next if reg.reg_paid?

      if reg.competitor
        old_item = old_comp_item
        new_item = new_comp_item
      else
        old_item = old_noncomp_item
        new_item = new_noncomp_item
      end

      if old_item.nil?
        # search for _ANY_ reg item
        old_rei = reg.registrant_expense_items.where({:expense_item_id => all_reg_items}).first
      else
        old_rei = reg.registrant_expense_items.where({:expense_item_id => old_item.id}).first
      end
      if old_rei.nil?
        missing_regs << reg.bib_number
      else
        next if old_rei.expense_item == new_item
        next if old_rei.locked # don't update "locked" items
        old_rei.destroy
      end

      #create the new reg item
      unless new_item.nil?
        reg.registrant_expense_items.create({:expense_item_id => new_item.id, :system_managed => true})
      end
    end

    if missing_regs.count > 0
      Notifications.missing_old_reg_items(missing_regs).deliver
    end

    old_period.update_attribute(:current_period, false) unless old_period.nil?
    now_period.update_attribute(:current_period,  true) unless now_period.nil?

    true
  end

  def self.update_checked_recently(date = Date.today)
    last_update_date = Rails.cache.fetch("/registration_period/last_update_run_date")
    return false if last_update_date.nil?

    last_update_date + 2.days >= date
  end
end
