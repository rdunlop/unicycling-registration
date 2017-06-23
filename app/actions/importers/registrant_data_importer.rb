# Import the registrant-sign-up and details
class Importers::RegistrantDataImporter < Importers::BaseImporter
  def process(file, processor)
    return false unless valid_file?(file)

    registrant_data = processor.extract_file(file)
    self.num_rows_processed = 0
    self.errors = nil
    Registrant.transaction do
      registrant_data.each do |registrant_hash|
        # CsvExtractor converts from file into array-of-arrays
        # Processor converts from array-of-arrays into array of hashes of form:
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
        # for each remaining column in the import, search for the matching Event
        # format of column headers:
        # Event: <name>
        # Event Best Time: <name>
        # Event Choice: <name>. Choice: <choice name>

        #   If the column is empty, ensure the user is not-signed-up
        #   else
        #     If the event takes best times
        #       if value is formatted with a ":", enter it as minutes/seconds.
        #       if value is formatted with a ".", enter it as seconds/thousands

        if build_and_save_imported_result(registrant_hash, @user)
          self.num_rows_processed += 1
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end

  # Public: Create an Registrant object.
  # Throws an exception if not valid
  def build_and_save_imported_result(registrant_hash, user)
    registrant = find_existing_registrant(registrant_hash)
    registrant.gender = if registrant_hash[:gender] == "m"
                          "Male"
                        else
                          "Female"
                        end
    registrant.user = user

    set_event_sign_ups(registrant, registrant_hash[:events])
    registrant.save!
    # if we already have a registrant matching this name+birthday+gender
    # else create a new registrant with this name+birthday+gender

    # for each remaining column in the import, search for the matching Event
    # format of column headers:
    # Event: <name>
    # Event Best Time: <name>
    # Event Choice: <name>. Choice: <choice name>

    Registrant.create!(user: user)
  end

  # finds existing registrant, or initializes a new one
  def find_existing_registrant(registrant_hash)
    existing_registrant(registrant_hash) || new_registrant(registrant_hash)
  end

  def existing_registrant(registrant_hash)
    # case-insensitive search
    Registrant
      .where(Registrant.arel_table[:first_name].lower.matches(registrant_hash[:first_name].downcase))
      .where(Registrant.arel_table[:last_name].lower.matches(registrant_hash[:last_name].downcase))
      .where(birthday: parse_birthday(registrant_hash[:birthday])).first
  end

  def new_registrant(registrant_hash)
    Registrant.new(
      first_name: registrant_hash[:first_name],
      last_name: registrant_hash[:last_name],
      birthday: parse_birthday(registrant_hash[:birthday])
    )
  end

  def set_event_sign_ups(registrant, events_hash)
    events_hash.each do |event_hash|
      set_event_sign_up(registrant, event_hash)
    end
  end

  # {
  #   name: "100m",
  #   signed_up: true,
  #   best_time: "20.03",
  #   choices: [
  #     { "Team Name" => 100m" }
  #   ],
  # }
  def set_event_sign_up(registrant, event_hash)
    event = Event.find_by!(name: event_hash[:name])
    resu = registrant.registrant_event_sign_ups.build(event: event)
    resu.signed_up = event_hash[:signed_up]
    resu.event_category = event.event_categories.first
    resu.save!
  end

  def parse_birthday(birthday, day_first: true)
    fmt = day_first ? "%d/%m/%y" : "%m/%d/%y"

    Date.strptime(birthday, fmt)
  end
end
