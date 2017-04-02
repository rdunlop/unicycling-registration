class RegistrantPresenter
  attr_accessor :registrant

  def initialize(registrant)
    @registrant = registrant
  end

  delegate :signed_up_events, :registrant_choices, :registrant_best_times, to: :registrant

  def describe_event(event)
    details = describe_event_hash(event)
    description = details[:description]

    unless details[:category].nil?
      description += " - Category: " + details[:category]
    end

    unless details[:additional].nil?
      description += " - " + details[:additional]
    end
    description
  end

  def describe_event_hash(event)
    results = {}
    results[:description] = event.name

    resu = signed_up_events.detect { |sue| sue.event_id == event.id }
    # only add the Category if there are more than 1
    results[:category] = (resu.event_category_name unless resu.nil?)

    results[:additional] = describe_additional_selection(event)

    results
  end

  def describe_additional_selection(event)
    results = []

    event.event_choices.each do |ec|
      my_val = registrant_choices.find_by(event_choice_id: ec.id)
      if my_val.present? && my_val.has_value?
        results << ec.label + ": " + my_val.describe_value
      end
    end

    registrant_best_times.where(event: event).find_each do |rbt|
      results << rbt.to_s
    end

    results.join(" - ") if results.any?
  end
end
