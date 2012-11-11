class AttendingController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :registrant

  before_filter :load_registrant

  def load_registrant
    @registrant = Registrant.find(params[:id])
  end

  def new
    @categories = Category.all.sort {|a,b| a.position <=> b.position}

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def create
    rcf = RegistrantChoicesFacade.new(@registrant)
    choices = params[:event_choices]
    choices.each do |choice, value|
      rcf.send("#{choice}=", value)
    end

    respond_to do |format|
      format.html { redirect_to @registrant }
    end
  end
end
