# Assumes model has a `birthday` field
#
module CalculatedAge
  extend ActiveSupport::Concern

  def determined_age
    start_date = EventConfiguration.singleton.effective_age_calculation_base_date
    if start_date.nil? || birthday.nil?
      99
    else
      age_at_event_date(start_date)
    end
  end

  def age_at_event_date(event_date)
    if (birthday.month < event_date.month) || (birthday.month == event_date.month && birthday.day <= event_date.day)
      event_date.year - birthday.year
    else
      (event_date.year - 1) - birthday.year
    end
  end
end
