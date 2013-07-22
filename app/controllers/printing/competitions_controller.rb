class Printing::CompetitionsController < ApplicationController
  before_filter :authenticate_user!
  skip_authorization_check

  before_filter :load_competition

  def load_competition
    @competition = Competition.find(params[:id])
  end

  def show
    respond_to do |format|
      format.html # multi_lap.html.erb
      format.pdf { render :pdf => "show", :formats => [:html], :orientation => 'Portrait', :layout => "pdf.html" }
    end
  end

  def announcer
    respond_to do |format|
      format.html # multi_lap.html.erb
      format.pdf { render :pdf => "announcer", :formats => [:html], :orientation => 'Portrait', :layout => "pdf.html" }
    end
  end
end

