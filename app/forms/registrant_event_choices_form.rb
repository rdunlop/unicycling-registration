# Helper class for dealing with displaying an event-sign-up form
# displaying all of the various sundry choices
class RegistrantEventChoicesForm
  attr_reader :registrant, :event, :current_user, :config

  def initialize(registrant, event, current_user, config)
    @registrant = registrant
    @event = event
    @current_user = current_user
    @config = config
  end

  def registrant_event_sign_up
    registrant.registrant_event_sign_ups.each do |resu|
      if resu.event_id == event.id
        return resu
      end
    end

    nil
  end

  def disabled_event?
    if !Pundit.policy(current_user, current_user).under_development? && config.can_only_drop_or_modify_events? && !registrant_event_sign_up.signed_up?
      return true
    end

    event.artistic? && !Pundit.policy(current_user, current_user).add_artistic_events?
  end

  def paid_for?
    event.has_cost? && registrant.paid_or_pending_expense_items.include?(event.expense_item)
  end

  def event_categories
    list = []
    event.event_categories.each do |cat|
      list << [cat.name, cat.id]
    end
    list
  end

  def inaccessible_event_categories
    disabled_list = []
    event.event_categories.each do |cat|
      unless cat.age_is_in_range(registrant.age)
        disabled_list << cat.id
      end
    end
    disabled_list
  end

  def event_choices_and_registrant_choices
    results = []
    event.event_choices.each do |choice|
      found_rc = nil
      registrant.registrant_choices.each do |rc|
        next unless rc.event_choice_id == choice.id
        found_rc = rc
        results << [choice, found_rc]
        break
      end
      unless found_rc
        results << [choice, nil]
      end
    end

    results
  end

  def best_time
    @registrant.registrant_best_times.each do |bt|
      if bt.event_id == event.id
        return bt
      end
    end

    nil
  end
end
