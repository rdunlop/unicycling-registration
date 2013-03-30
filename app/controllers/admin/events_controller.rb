class Admin::EventsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @num_competitors = Registrant.where({:competitor => true}).count
    @num_non_competitors = Registrant.where({:competitor => false}).count
    @num_registrants = @num_competitors + @num_non_competitors
  end

  def show

    respond_to do |format|
      format.html { render action: "show" } #, :layout => nil }
      format.pdf { render :pdf => "show", :formats => [:html] }
    end
  end
end
