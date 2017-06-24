# Export Registrant and Event-Sign-Up information
class Exporters::RegistrantExporter
  def headers
    [
      "ID",
      "First Name",
      "Last Name",
      "Birthday (dd/mm/yy)",
      "Sex (m/f)"
    ] + event_headers
  end

  def rows
    Registrant.all.map do |registrant|
      [
        registrant.bib_number.to_s,
        registrant.first_name,
        registrant.last_name,
        registrant.birthday.strftime("%d/%m/%y"),
        registrant.gender == "Male" ? "m" : "f"
      ] + event_rows(registrant)
    end
  end

  private

  def events
    @events ||= Event.all.order(:id).includes(:event_categories, :event_choices)
  end

  def event_headers
    result = []
    events.map do |event|
      result << "EV: #{event.name} - Signed Up (Y/N)"
      result << "EV: #{event.name} - Best Time (none)"

      category_names = event.event_categories.map(&:name).join("/")
      result << "EV: #{event.name} - Category (#{category_names})"

      event.event_choices.each do |event_choice|
        result << "EV: #{event.name} - Choice: #{event_choice.label}"
      end
    end

    result
  end

  def event_rows(registrant)
    result = []

    events.map do |event|
      resu = registrant.registrant_event_sign_ups.find{ |resup| resup.event == event }
      if resu&.signed_up?
        result << "Y"

        rbt = registrant.registrant_best_times.find{|rbtime| rbtime.event == event }
        if rbt
          result << rbt.formatted_value
        else
          result << ""
        end

        result << resu.event_category.name
        event.event_choices.each do |event_choice|
          rc = registrant.registrant_choices.find{|rchoice| rchoice.event_choice == event_choice }
          result << rc.value
        end
      else
        result << "N"
        result << "" # best time
        result << "" # event category

        event.event_choices.each do |_event_choice|
          result << ""
        end
      end
    end

    result
  end
end
