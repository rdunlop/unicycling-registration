# == Schema Information
#
# Table name: registration_periods
#
#  id                            :integer          not null, primary key
#  start_date                    :date
#  end_date                      :date
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  competitor_expense_item_id    :integer
#  noncompetitor_expense_item_id :integer
#  onsite                        :boolean          default(FALSE), not null
#  current_period                :boolean          default(FALSE), not null
#

class RegistrationPeriod < ActiveRecord::Base
  include CachedModel

  default_scope { order(:start_date) }

  validates :start_date, :end_date, :competitor_expense_item, :noncompetitor_expense_item, :presence => true

  translates :name, fallbacks_for_empty_translations: true
  accepts_nested_attributes_for :translations

  belongs_to :competitor_expense_item, :class_name => "ExpenseItem", dependent: :destroy
  accepts_nested_attributes_for :competitor_expense_item
  belongs_to :noncompetitor_expense_item, :class_name => "ExpenseItem", dependent: :destroy
  accepts_nested_attributes_for :noncompetitor_expense_item

  validates :onsite, :inclusion => { :in => [true, false] } # because it's a boolean

  after_save :clear_cache
  after_destroy :clear_cache

  alias_attribute :to_s, :name

  def clear_cache
    Rails.cache.delete("/registration_period/by_date/#{Date.today}")
  end

  # We allow registrations to arrive 1 day _after_ the end date,
  # to account for timezone differences, and 'last minute' shoppers.
  def last_day
    self.end_date + 1.day
  end

  def current_period?(date = Date.today)
    (self.start_date <= date && date <= last_day)
  end

  def past_period?(date = Date.today)
    (self.last_day < date)
  end

  def self.last_online_period
    last_period = nil
    RegistrationPeriod.all.each do |rp|
      next if rp.onsite
      last_period = rp
    end
    last_period
  end

  def last_online_period?
    self == RegistrationPeriod.last_online_period
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
    nil
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

  def self.update_registration_periods
    Apartment.tenant_names.each do |tenant|
      Apartment::Tenant.switch(tenant)
      update_current_period
    end
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

    Notifications.delay.updated_current_reg_period(old_period.try(:name), now_period.try(:name))

    missing_regs = []

    unless now_period.nil?
      Registrant.all.each do |reg|
        new_item = now_period.expense_item_for(reg.competitor)

        next if new_item.nil?

        if !reg.set_registration_item_expense(new_item, false)
          missing_regs << reg.bib_number
        end
      end
    end

    if missing_regs.any?
      Notifications.delay.missing_old_reg_items(missing_regs)
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

  def expense_item_for(is_competitor)
    if is_competitor
      competitor_expense_item
    else
      noncompetitor_expense_item
    end
  end
end
