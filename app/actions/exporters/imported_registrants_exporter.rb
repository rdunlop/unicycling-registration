class Exporters::ImportedRegistrantsExporter
  def initialize(registrants)
    @registrants = registrants
  end

  def headers
    ["Id", "First Name", "Last Name", "Age", "Birthday (yyyy/mm/dd)", "Club"]
  end

  def rows
    results = []
    @registrants.each do |reg|
      results << [
        reg.bib_number,
        reg.first_name,
        reg.last_name,
        reg.age,
        reg.birthday.try(:strftime, "%Y/%m/%d"),
        reg.club
      ]
    end

    results
  end
end
