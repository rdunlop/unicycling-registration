# CsvExtractor converts from file into array-of-arrays
# Processor converts from array-of-arrays into array of hashes
# {
#   id: "1",
#   first_name: "Bob",
#   last_name: "Smith",
#   birthday: "10/4/76",
#   gender: "m",
#   events: [
#      {
#        name: "100m",
#        signed_up: true,
#        best_time: "20.03",
#        choices: [
#          { "Team Name" => 100m" }
#        ],
#      }
#   ]
# }
class Importers::Parsers::RegistrantImport < Importers::Parsers::Base
  class ElementFinder
    def initialize(headers, row = nil)
      @headers = headers
      @row = row
    end

    def find(element_name)
      target_index = find_column(element_name)
      @row[target_index]
    end

    def find_column(element_name)
      @headers.find_index(element_name)
    end
  end

  def initialize(file = nil)
    super(file)
  end

  def extract_file
    arrays = Importers::CsvExtractor.new(file).extract_csv
    @headers = arrays[0]
    arrays.drop(1)
  end

  def process_row(row)
    convert_row(@headers, row)
  end

  def validate_contents
    validate_headers
  end

  def validate_headers
    element_finder = ElementFinder.new(@headers)
    Event.all.each do |event|
      unless element_finder.find_column("EV: #{event.name} - Signed Up (Y/N)")
        @errors << "Unable to find event #{event.name}"
      end
    end
  end

  def events
    @events ||= Event.all.order(:id).includes(:event_categories, :event_choices)
  end

  def convert_row(header, row)
    element_finder = ElementFinder.new(header, row)
    {
      id: element_finder.find("ID"),
      first_name: element_finder.find("First Name"),
      last_name: element_finder.find("Last Name"),
      birthday: element_finder.find("Birthday (dd/mm/yyyy)"),
      gender: element_finder.find("Sex (m/f)"),
      events: event_data(element_finder)
    }
  end

  # Input columns:
  # EV: 100m - Signed Up (Y/N)
  # EV: 100m - Category (All)
  # EV: 100m - Best Time ((m)m:ss.xx)
  # EV: 100m - Choice: Team Name

  # Output Data:
  # {
  #   name: "100m",
  #   category: "All"
  #   signed_up: true,
  #   best_time: "20.03",
  #   choices: [
  #     { "Team Name" => "100m Team" }
  #   ]
  # }
  def event_data(element_finder)
    events.map do |event|
      category_names = event.event_categories.map(&:name).join("/")
      event_hash = {
        name: event.name,
        category: element_finder.find("EV: #{event.name} - Category (#{category_names})"),
        signed_up: (element_finder.find("EV: #{event.name} - Signed Up (Y/N)") == "Y"),
        best_time: element_finder.find("EV: #{event.name} - Best Time (#{event.best_time_format})")
      }

      choices = {}
      event.event_choices.each do |event_choice|
        choices[event_choice.label] = element_finder.find("EV: #{event.name} - Choice: #{event_choice.label}")
      end

      event_hash[:choices] = choices
      event_hash
    end
  end
end
