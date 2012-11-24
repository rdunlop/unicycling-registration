class RegistrantChoicesFacade

  # This class encompasses the dynamic fields nature of the Registrant->EventChoice relationship
  # 
  # If you create a RegistrantChoiceFacade r, and then you can look up that registrant's
  # choices via r.choice123 (look for the event_choice with id 123, and see this registrant's selection)
  # and r.choice123="1" (set the event_choice with id 123 for this registrant)
  #
  
  attr_accessor :registrant

  def initialize(registrant)
    @registrant = registrant
  end

  # as per http://stackoverflow.com/questions/291132/method-missing-gotchas-in-ruby
  # I MAY want to enhance this re: http://dondoh.tumblr.com/post/4142258573/formtastic-without-activerecord

  def respond_to?(sym)
    valid_choice?(sym) || super(sym)
  end

  def method_missing(sym, *args, &block)
    if valid_choice?(sym)
      if sym[-1] == "="
        return set_value(sym, *args)
      else
        return get_value(sym)
      end
    end
    return super(sym, args, block)
  end

  # combine this and get_value to do the EventChoice lookup only once
  def valid_choice?(sym)
    sym.to_s =~ /^choice/
  end

  def get_value(sym)
    event_choice = EventChoice.find(sym[/choice(\d+)/,1])

    choices = @registrant.registrant_choices.where({:event_choice_id => event_choice.id})
    if event_choice.cell_type == 'boolean'
      if choices.count > 0
        if choices.first.value == "1"
          true
        else
          false
        end
      else
        false
      end
    else
      if choices.count > 0
        choices.first.value
      else
        nil
      end
    end
  end

  # given the registrant, and the sym (choice), set/update the value
  def set_value(sym, args)
    event_choice = EventChoice.find(sym[/choice(\d+)/,1])
    existing_entry = RegistrantChoice.where({:registrant_id => @registrant.id, :event_choice_id => event_choice.id})
    if existing_entry.count == 0
      entry = RegistrantChoice.new
    else
      entry = existing_entry.first
    end
    entry.registrant = @registrant
    entry.event_choice = event_choice
    if event_choice.cell_type == "boolean"
      if args == "1"
        entry.value = "1"
      else
        entry.destroy
        return
      end
    else
      if args.empty?
        entry.destroy
        return
      else
        entry.value = args
      end
    end
    entry.save!
  end


  # does this registrant have this event checked off?
  def has_event?(event)
    enablement_choice = EventChoice.where({:event_id => event.id, :position => 1})
    if enablement_choice.empty?
      false
    else
      self.get_value(enablement_choice.first.choicename)
    end
  end

  def describe_event(event)
    description = event.name

    details = EventChoice.where({:event_id => event.id})
    details.all.each do |ec|
      if ec.position != 1
        my_val = self.get_value(ec.choicename)
        unless my_val.nil?
          description += " - " + ec.label + ": " + my_val
        end
      end
    end
    description
  end
end
