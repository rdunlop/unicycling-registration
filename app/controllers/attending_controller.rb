class AttendingController < ApplicationController
  before_filter :load_registrant

  def load_registrant
    @registrant = Registrant.find(params[:id])
  end

  def new
    @events = Event.all.sort {|a,b| a.position <=> b.position}

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def create
    choices = params[:event_choices]
    choices.each do |choice, value|
      @ec = EventChoice.find(choice.to_i)
      existing_entry = RegistrantChoice.where({:registrant_id => @registrant.id, :event_choice_id => @ec.id})

      if existing_entry.count == 0
        entry = RegistrantChoice.new
      else
        entry = existing_entry.first
      end
      entry.registrant = @registrant
      entry.event_choice = @ec
      entry.value = value
      entry.save!
    end

    respond_to do |format|
      format.html { redirect_to @registrant }
    end
  end
end
