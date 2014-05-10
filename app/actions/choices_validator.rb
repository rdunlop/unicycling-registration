class ChoicesValidator
  attr_accessor :registrant

  def initialize(registrant)
    @registrant = registrant
  end

  def registrant_choices
    @registrant_choices ||= @registrant.registrant_choices
  end

  def validate
    # for each event that we have choices made
    # determine if we have values for ALL or NONE of the choices for that event
    # loop
    sign_up_events = @registrant.registrant_event_sign_ups.map{|resu| resu.event}
    choice_events = registrant_choices.map{|rc| rc.event_choice}.map{|ec| ec.event}

    events_to_validate = sign_up_events + choice_events

    events_to_validate.uniq.each do |event|
      validate_event event
    end

    true
  end

  def validate_event(event)
    event_selected = signed_up_for(event)
    event.event_choices.each do |event_choice|
      # using .select instead of .where, because we need to validate not-yet-saved data
      reg_choice = get_choice_for_event_choice(event_choice)

      if !valid_event_choice_registrant_choice(event_selected, event_choice, reg_choice)
        mark_event_sign_up_as_error(event)
      end
    end
  end

  def reg_sign_up_record_for(event)
    @registrant.registrant_event_sign_ups.select{|resu| resu.event_id == event.id}.first
  end

  def signed_up_for(event)
    primary_choice_selected = reg_sign_up_record_for(event)

    primary_choice_selected.present? && primary_choice_selected.signed_up
  end

  def valid_event_choice_registrant_choice(event_selected, event_choice, reg_choice)
    optional_if_event_choice = event_choice.optional_if_event_choice
    required_if_event_choice = event_choice.required_if_event_choice

    reg_choice_chosen = reg_choice.present? && reg_choice.has_value?

    if event_selected && !valid_with_required_selection(event_choice, reg_choice_chosen)
      @registrant.errors[:base] << "#{event_choice.to_s } must be specified if #{required_if_event_choice.to_s} is chosen"
      return false
    end

    if event_selected && !valid_with_optional_selection(event_choice, reg_choice_chosen)
      @registrant.errors[:base] << "#{event_choice.to_s } must be specified unless #{optional_if_event_choice.to_s} is chosen"
      return false
    end

    return true if event_choice.optional
    return true if optional_if_event_choice.present? # we passed the optional check, so we shouldn't complain
    return true if required_if_event_choice.present? # we passed the required check, so we shouldn't complain

    if event_selected
      if reg_choice.nil? or not reg_choice.has_value?
        return true if event_choice.cell_type == "boolean"
        @registrant.errors[:base] << "#{event_choice.to_s} must be specified"
        reg_choice.errors[:value] = "" unless reg_choice.nil?
        reg_choice.errors[:event_category_id] = "" unless reg_choice.nil?
        return false
      end
    else
      if reg_choice.present? and reg_choice.has_value?
        @registrant.errors[:base] << "#{event_choice.to_s} cannot be specified if the event isn't chosen"
        reg_choice.errors[:value] = "" unless reg_choice.nil?
        reg_choice.errors[:event_category_id] = "" unless reg_choice.nil?
        return false
      end
    end
    true
  end

  def valid_with_required_selection(event_choice, reg_choice_chosen)
    required_if_event_choice = event_choice.required_if_event_choice

    unless required_if_event_choice.nil?

      required_reg_choice = get_choice_for_event_choice(required_if_event_choice)
      required_has_value = required_reg_choice.present? && required_reg_choice.has_value?

      if event_choice_chosen?(required_if_event_choice)
        # the required choice IS selected
        if not reg_choice_chosen
          # the choice isn't selected, and the -required- element is chosen
          return false
        end
      end
    end
    true
  end

  def valid_with_optional_selection(event_choice, reg_choice_chosen)
    return true if event_choice.optional
    optional_if_event_choice = event_choice.optional_if_event_choice

    # check to see if this is optional by way of another choice
    unless optional_if_event_choice.nil?

      if not event_choice_chosen?(optional_if_event_choice)
        # the optional choice isn't selected
        if not reg_choice_chosen
          # this option is NOT selected, but the optional ISN'T either
          return false
        end
      else
        # the optional choice IS selected
        # it doesn't matter whether we have a chosen value or not
        return true
      end
    end
    true
  end

  def get_choice_for_event_choice(event_choice)
    registrant_choices.select{|rc| rc.event_choice_id == event_choice.id}.first
  end

  def event_choice_chosen?(event_choice)
    ec = get_choice_for_event_choice(event_choice)
    ec.present? && ec.has_value?
  end

  def mark_event_sign_up_as_error(event)
    primary_choice_selected = reg_sign_up_record_for(event)
    primary_choice_selected.errors[:signed_up] = "" unless primary_choice_selected.nil? # the primary checkbox
  end


end
