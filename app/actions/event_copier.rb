class EventCopier
  attr_reader :subdomain, :successes, :errors, :error_events

  def initialize(subdomain)
    @subdomain = subdomain
    @successes = 0
    @errors = 0
    @error_events = []
  end

  def create_categories
    source_categories.each do |category|
      new_category = category.dup
      new_category.name = category.name
      category.translations.each do |translation|
        new_category.translations << translation.dup
      end
      new_category.save
    end
  end

  def copy_events
    create_categories

    source_events.each do |event|
      if create_event(event)
        @successes += 1
      else
        @errors += 1
        @error_events << event.name
      end
    end
  end

  private

  def create_event(source_event)
    new_event = source_event.dup
    new_event.name = source_event.name
    new_event.category = Category.find_by(name: source_event.category.name)

    # Set the event_categories before saving the event, to prevent creating the default 'All' EventCategory
    source_event.event_categories.each do |ec|
      new_event_category = ec.dup
      new_event_category.name = ec.name
      # necessary to avoid uniqueness errors, because the event_id is not
      # cleared until AFTER validation is performed on EventCategory
      new_event_category.event = nil
      ec.translations.each do |translation|
        new_event_category.translations << translation.dup
      end
      new_event.event_categories << new_event_category
    end

    source_event.translations.each do |translation|
      new_event.translations << translation.dup
    end

    if new_event.save # save the Event and EventCategories
      source_event.event_choices.each do |ec|
        new_ec = ec.dup
        new_ec.label = ec.label
        new_ec.tooltip = ec.tooltip
        ec.translations.each do |translation|
          new_ec.translations << translation.dup
        end
        new_event.event_choices << new_ec # this causes the save
      end

      source_event.event_choices.each do |ec|
        new_ec = new_event.event_choices.find { |search_ec| search_ec.label == ec.label }
        if ec.optional_if_event_choice_id.present?
          optional_ec = source_event.event_choices.find { |search_ec| search_ec.id == ec.optional_if_event_choice_id }
          new_ec.optional_if_event_choice = new_event.event_choices.find_by(label: optional_ec.label)
          new_ec.save
        end
        next unless ec.required_if_event_choice_id.present?

        required_ec = source_event.event_choices.find { |search_ec| search_ec.id == ec.required_if_event_choice_id }
        new_ec.required_if_event_choice = new_event.event_choices.find_by(label: required_ec.label)
        new_ec.save
      end

      true
    else
      false
    end
  end

  def source_events
    return @events if @events
    Apartment::Tenant.switch subdomain do
      @events = Event.all.includes(:translations, event_categories: :translations, category: :translations, event_choices: :translations).load
    end

    @events
  end

  def source_categories
    @categories = nil
    Apartment::Tenant.switch subdomain do
      @categories = Category.all.includes(:translations).load
    end

    @categories
  end
end
