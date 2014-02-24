class Printing::CompetitionsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource :competition, :parent => false

  before_filter :load_competition

  def load_competition
    @competition = Competition.find(params[:id])
  end

  def announcer
    respond_to do |format|
      format.html # multi_lap.html.erb
      format.pdf { render_common_pdf("announcer") }
    end
  end

  def heat_recording
    @competition_sign_up = CompetitionSignUp.new(@competition)

    respond_to do |format|
      format.html 
      format.pdf { render_common_pdf("heat_recording") }
    end
  end

  def two_attempt_recording
    @competition_sign_up = CompetitionSignUp.new(@competition)
    @no_page_breaks = true unless params[:no_page_breaks].nil?

    @only_registered = true
    @only_registered = false if params[:only_registered].nil?

    respond_to do |format|
      format.html 
      format.pdf { render_common_pdf("two_attempt_recording") }
    end
  end

  def results

    @age_group_entries = @competition.age_group_entries
    @results_list = @competition.results_list

    @no_page_breaks = true unless params[:no_page_breaks].nil?

    respond_to do |format|
      format.html 
      format.pdf { render_common_pdf("results", "Portrait") }
    end
  end

  def save
    @age_group_entries = @competition.age_group_entries
    @results_list = @competition.results_list

    @no_page_breaks = true #unless params[:no_page_breaks].nil?

    respond_to do |format|
      format.html 
      format.pdf { render :pdf => "#{EventConfiguration.short_name.tr(" ", "_")}_#{@competition.name.tr(" ", "_")}_results", :formats => [:html], :orientation => 'Portrait', :layout => "pdf.html", :disposition => "attachment" }
    end
  end
end

