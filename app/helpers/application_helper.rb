module ApplicationHelper
  def setup_registrant_choices(registrant)
    EventChoice.all.each do |ec|
      if registrant.registrant_choices.where({:event_choice_id => ec.id}).empty?
        new_cc = registrant.registrant_choices.build
        new_cc.event_choice_id = ec.id
      end
    end
    registrant
  end
end
