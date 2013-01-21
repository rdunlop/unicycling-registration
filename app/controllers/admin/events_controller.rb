class Admin::EventsController < Admin::BaseController
  before_filter :authenticate_user!
  skip_authorization_check # XXX because I'm using the BaseController for auth

  def index
    @events = Event.all
    @num_competitors = Registrant.where({:competitor => true}).count
    @num_non_competitors = Registrant.where({:competitor => false}).count
    @num_registrants = @num_competitors + @num_non_competitors
  end
end
