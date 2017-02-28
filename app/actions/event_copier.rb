class EventCopier
  attr_reader :subdomain, :successes, :errors, :error_events

  def initialize(subdomain)
    @subdomain = subdomain
    @successes = 0
    @errors = 0
    @error_events = []
  end

  def copy_events
    events = nil
    categories = nil
    Apartment::Tenant.switch subdomain do
      events = Event.all.includes(:event_categories, :translations, category: :translations, event_choices: :translations).load
      categories = Category.all.includes(:translations).load
    end

    categories.each do |category|
      new_category = category.dup
      new_category.name = category.name
      new_category.save
    end

    events.each do |event|
      new_event = event.dup
      new_event.name = event.name
      new_event.category = Category.find_by(name: event.category.name)
      if new_event.save
        event.event_choices.each do |ec|
          new_ec = ec.dup
          new_ec.label = ec.label
          new_ec.tooltip = ec.tooltip
          new_event.event_choices << new_ec # this causes the save
        end

        event.event_choices.each do |ec|
          new_ec = new_event.event_choices.find { |search_ec| search_ec.label == ec.label }
          if ec.optional_if_event_choice_id.present?
            optional_ec = event.event_choices.find { |search_ec| search_ec.id == ec.optional_if_event_choice_id }
            new_ec.optional_if_event_choice = new_event.event_choices.find_by(label: optional_ec.label)
            new_ec.save
          end
          if ec.required_if_event_choice_id.present?
            required_ec = event.event_choices.find { |search_ec| search_ec.id == ec.required_if_event_choice_id }
            new_ec.required_if_event_choice = new_event.event_choices.find_by(label: required_ec.label)
            new_ec.save
          end
        end

        event.event_categories.each do |ec|
          new_event_category = ec.dup
          new_event_category.name = ec.name
          new_event.event_categories << new_event_category # this causes the save
        end
        @successes += 1
      else
        @errors += 1
        @error_events << event.name
      end
    end
  end
end
