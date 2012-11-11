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
      rc = RegistrantChoice.new
      rc.registrant = @registrant
      rc.event_choice = EventChoice.find(choice.to_i)
      rc.value = value
      rc.save
    end

    respond_to do |format|
      format.html { redirect_to @registrant }
    end
  end

  def edit
    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  def update
    respond_to do |format|
      format.html { redirect_to @registrant }
    end
  end
end
