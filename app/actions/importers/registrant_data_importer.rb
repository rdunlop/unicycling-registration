# Import the registrant-sign-up and details
class Importers::RegistrantDataImporter < Importers::BaseImporter
  def process(processor)
    unless processor.valid_file?
      @errors = processor.errors
      return false
    end

    registrant_data = processor.file_contents
    self.num_rows_processed = 0
    @errors = []
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

        begin
          if build_and_save_imported_result(registrant_hash, @user)
            self.num_rows_processed += 1
          end
        rescue ActiveRecord::RecordInvalid => invalid
          invalid.record.errors.full_messages.each do |error_message|
            @errors << "#{invalid.record}: #{error_message}"
          end
        end
      end
    end

    @errors.none?
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
    registrant.status = "base_details"
    registrant.save!
    set_events_sign_ups(registrant, registrant_hash[:events])
    set_events_best_times(registrant, registrant_hash[:events])
    set_events_choices(registrant, registrant_hash[:events])
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

  def set_events_sign_ups(registrant, events_hash)
    events_hash.each do |event_hash|
      set_event_sign_up(registrant, event_hash)
    end
  end

  def set_events_choices(registrant, events_hash)
    events_hash.each do |event_hash|
      set_event_choice(registrant, event_hash)
    end
  end

  def set_events_best_times(registrant, events_hash)
    events_hash.each do |event_hash|
      set_event_best_time(registrant, event_hash)
    end
  end

  def event_by_name(name)
    if @events.nil?
      @events = Event.all.includes(event_categories: [:translations], event_choices: [:translations])
    end

    @events.find{|ev| ev.name == name }
  end

  # {
  #   name: "100m",
  #   category: "All",
  #   signed_up: true,
  #   best_time: "20.03",
  #   choices: [
  #     { "Team Name" => 100m" }
  #   ],
  # }
  def set_event_sign_up(registrant, event_hash)
    event = event_by_name(event_hash[:name])
    resu = registrant.registrant_event_sign_ups.find_or_initialize_by(event: event)
    resu.signed_up = event_hash[:signed_up]
    resu.event_category = event.event_categories.find{|event_category| event_category.name == event_hash[:category] }
    resu.save!
  end

  def set_event_choice(registrant, event_hash)
    return unless event_hash[:signed_up]
    event = event_by_name(event_hash[:name])
    event.event_choices.each do |event_choice|
      resu = registrant.registrant_choices.find_or_initialize_by(event_choice: event_choice)
      resu.value = event_hash[:choices][event_choice.label]
      resu.save!
    end
  end

  def set_event_best_time(registrant, event_hash)
    return unless event_hash[:signed_up]
    return if event_hash[:best_time].blank?
    event = event_by_name(event_hash[:name])
    return if event.best_time_format == "none"
    rebt = registrant.registrant_best_times.find_or_initialize_by(event: event)
    rebt.formatted_value = event_hash[:best_time]
    rebt.source_location = "N/A"
    rebt.save!
  end

  def parse_birthday(birthday, day_first: true)
    fmt = day_first ? "%d/%m/%Y" : "%m/%d/%Y"

    Date.strptime(birthday, fmt)
  end
end
