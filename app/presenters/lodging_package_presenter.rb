class LodgingPackagePresenter
  include ApplicationHelper

  attr_reader :lodging_package

  def initialize(lodging_package)
    @lodging_package = lodging_package
  end

  def check_in_day
    date = lodging_package.lodging_package_days.map(&:date_offered).sort.first
    output_entry(date)
  end

  def check_out_day
    date = lodging_package.lodging_package_days.map(&:date_offered).sort.last + 1.day
    output_entry(date)
  end

  def location
    "#{lodging_package.lodging_room_type} - #{lodging_package.lodging_room_option}"
  end

  def to_s
    "#{location} - #{check_in_day}-#{check_out_day}"
  end

  private

  def output_range(start_date, end_date)
    if start_date == end_date
      output_entry(start_date)
    else
      "#{output_entry(start_date)} - #{output_entry(end_date)}"
    end
  end

  def output_entry(date)
    return "none" if date.blank?

    I18n.l(date, format: :lodging_date_format)
  end
end
