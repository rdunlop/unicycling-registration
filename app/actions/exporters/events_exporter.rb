class Exporters::EventsExporter
  def headers
    [
      "Id",
      "First Name",
      "Last Name",
      "Birthday",
      "Age",
      "Gender",
      "Club"
    ] + event_categories_titles + event_titles
  end

  def event_choices
    @event_choices ||= Event.includes(event_choices: %i[event translations]).flat_map{ |ev| ev.event_choices }
  end

  def event_titles
    event_choices.map{|ec| ec.to_s}
  end

  def event_categories
    @event_categories ||= Event.includes(event_categories: %i[event translations]).flat_map{ |ev| ev.event_categories }
  end

  def event_categories_titles
    event_categories.map{|ec| ec.to_s}
  end

  def rows
    competitor_data = []
    Registrant.active.includes(contact_detail: [], registrant_event_sign_ups: [], registrant_choices: :event_choice).each do |reg|
      reg_sign_up_data = []
      event_categories.each do |ec|
        # for performance reasons, loop it
        rc = nil
        reg.registrant_event_sign_ups.each do |r|
          if r.event_category_id == ec.id
            rc = r
            break
          end
        end
        # rc = reg.registrant_event_sign_ups.where({:event_category_id => ec.id}).first
        if rc.nil?
          reg_sign_up_data += [nil]
        else
          reg_sign_up_data += [rc.signed_up]
        end
      end

      reg_event_data = []
      event_choices.each do |ec|
        # for performance reasons, loop it
        rc = nil
        reg.registrant_choices.each do |r|
          if r.event_choice_id == ec.id
            rc = r
            break
          end
        end
        # rc = reg.registrant_choices.where({:event_choice_id => ec.id}).first
        if rc.nil?
          reg_event_data += [nil]
        else
          reg_event_data += [rc.describe_value]
        end
      end
      competitor_data << ([reg.bib_number, reg.first_name, reg.last_name, reg.birthday, reg.age, reg.gender, reg.club] + reg_sign_up_data + reg_event_data)
    end

    competitor_data
  end
end
