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
    ec = EventChoice.find(sym[/choice(\d+)/,1])
    @registrant.chose(ec)
  end

  # given the registrant, and the sym (choice), set/update the value
  def set_value(sym, args)
    ec = EventChoice.find(sym[/choice(\d+)/,1])
    existing_entry = RegistrantChoice.where({:registrant_id => @registrant.id, :event_choice_id => ec.id})
    if existing_entry.count == 0
      entry = RegistrantChoice.new
    else
      entry = existing_entry.first
    end
    entry.registrant = @registrant
    entry.event_choice = ec
    # boolean
    if args == true
      entry.value = "1"
    else
      entry.value = "0"
    end
    entry.save!
  end
end
