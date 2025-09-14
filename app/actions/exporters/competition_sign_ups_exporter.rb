class Exporters::CompetitionSignUpsExporter
  def headers
    [
      "Registrant Type",
      "Age",
      "Gender",
      "Club",
      "Country"
    ] + competition_titles
  end

  def competition_titles
    competitions.map do |competition|
      "#{competition.event.category} #{competition.event} #{competition}"
    end
  end

  def competitions
    return @competitions if defined?(@competitions)

    @competitions = []
    # This causes us to add the events in event-order
    Event.all.each do |event|
      @competitions += event.competitions.to_a # add each entry individually
    end
    @competitions
  end

  def rows
    competitor_data = []
    Registrant.active.includes(contact_detail: [], competitors: []).each do |reg|
      reg_sign_up_data = []
      competitions.each do |competition|
        # for performance reasons, loop it
        rc = nil
        reg.competitors.each do |r|
          if r.competition_id == competition.id
            rc = competition
            break
          end
        end

        if rc.nil?
          reg_sign_up_data += [nil]
        else
          reg_sign_up_data += [rc.to_s]
        end
      end

      competitor_data << ([reg.registrant_type, reg.age, reg.gender, reg.club, reg.country] + reg_sign_up_data)
    end

    competitor_data
  end
end
