module HoursFacade
  extend ActiveSupport::Concern
  # NOT YET fully tested to be working.
  def facade_minutes
    return nil if self[:minutes].blank?
    minutes % 60
  end

  def facade_minutes=(new_minutes)
    set_minutes(facade_hours || 0, new_minutes.to_i)
  end

  def facade_hours
    return nil if self[:minutes].blank?
    minutes / 60
  end

  def facade_hours=(new_hours)
    set_minutes(new_hours.to_i, facade_minutes || 0)
  end

  def facade_hundreds=(new_hundreds)
    self.thousands = new_hundreds.to_i * 10
  end

  def facade_hundreds
    return nil if thousands.blank?
    thousands / 10
  end

  private

  def set_minutes(hours, minutes)
    self.minutes = (hours * 60) + minutes
  end
end
