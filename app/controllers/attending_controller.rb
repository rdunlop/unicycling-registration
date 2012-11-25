class AttendingController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :registrant

  before_filter :load_registrant

  def load_registrant
    @registrant = Registrant.find(params[:id])
  end

  def load_categories
    @categories = Category.all.sort {|a,b| a.position <=> b.position}
  end

  def new
    load_categories

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create

    respond_to do |format|
      if @registrant.update_attributes(params[:registrant])
        format.html { redirect_to @registrant, notice: 'Attending was successfully created.' }
      else
        load_categories
        format.html { render action: "new" }
      end
    end
  end
end
