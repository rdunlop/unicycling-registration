class LodgingPackagePresenter
  include ApplicationHelper

  attr_reader :lodging_package

  def initialize(lodging_package)
    @lodging_package = lodging_package
  end

  def first_day
    date = lodging_package.lodging_package_days.map(&:date_offered).sort.first
    output_entry(date)
  end

  def last_day
    date = lodging_package.lodging_package_days.map(&:date_offered).sort.last
    output_entry(date)
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
