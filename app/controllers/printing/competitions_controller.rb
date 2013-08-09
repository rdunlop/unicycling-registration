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
      format.pdf { render_common_pdf("show") }
    end
  end

  def announcer
    respond_to do |format|
      format.html # multi_lap.html.erb
      format.pdf { render_common_pdf("announcer") }
    end
  end

  def heat_recording
    @all_registrants = Registrant.where(:competitor => true).order(:bib_number).all
    @signed_up_registrants = @competition.signed_up_registrants
    @agt = @competition.determine_age_group_type
    @age_group_entries = @agt.age_group_entries
    @signed_up_list = {}
    @not_signed_up_list = {}
    @age_group_entries.each do |ag_entry|
      @signed_up_list[ag_entry] = []
      @not_signed_up_list[ag_entry] = []
    end

    @all_registrants.each do |reg|
      calculated_ag = @agt.age_group_entry_for(reg.age, reg.gender, reg.default_wheel_size.id)
      if @signed_up_registrants.include?(reg)
        @signed_up_list[calculated_ag] << reg
      else
        @not_signed_up_list[calculated_ag] << reg
      end
    end

    respond_to do |format|
      format.html 
      format.pdf { render_common_pdf("heat_recording") }
    end
  end

  def two_attempt_recording
    @all_registrants = Registrant.where(:competitor => true).order(:bib_number).all
    @signed_up_registrants = @competition.signed_up_registrants
    @agt = @competition.determine_age_group_type
    @age_group_entries = @agt.age_group_entries
    @signed_up_list = {}
    @not_signed_up_list = {}
    @age_group_entries.each do |ag_entry|
      @signed_up_list[ag_entry] = []
      @not_signed_up_list[ag_entry] = []
    end

    @no_page_breaks = true unless params[:no_page_breaks].nil?

    @all_registrants.each do |reg|
      calculated_ag = @agt.age_group_entry_for(reg.age, reg.gender, reg.default_wheel_size.id)
      if @signed_up_registrants.include?(reg)
        @signed_up_list[calculated_ag] << reg
      else
        @not_signed_up_list[calculated_ag] << reg if params[:only_registered].nil?
      end
    end

    respond_to do |format|
      format.html 
      format.pdf { render_common_pdf("two_attempt_recording") }
    end
  end

  def results

    @age_group_entries = @competition.age_group_entries
    @results_list = @competition.results_list

    @no_page_breaks = true unless params[:no_page_breaks].nil?

    # sort the results by place
    @results_list.keys.each do |key|
      @results_list[key].sort!{|a,b| a.place.to_i <=> b.place.to_i}
    end

    respond_to do |format|
      format.html 
      format.pdf { render_common_pdf("results", "Portrait") }
    end
  end

  def save
    @age_group_entries = @competition.age_group_entries
    @results_list = @competition.results_list

    @no_page_breaks = true #unless params[:no_page_breaks].nil?

    # sort the results by place
    @results_list.keys.each do |key|
      @results_list[key].sort!{|a,b| a.place.to_i <=> b.place.to_i}
    end

    respond_to do |format|
      format.html 
      format.pdf { render :pdf => "#{EventConfiguration.short_name}_#{@competition.name}_results", :formats => [:html], :orientation => 'Portrait', :layout => "pdf.html", :disposition => "attachment" }
    end
  end
end

