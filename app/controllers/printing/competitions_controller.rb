class Printing::CompetitionsController < ApplicationController
  before_filter :authenticate_user!, except: [:announcer]
  before_filter :load_competition
  authorize_resource :competition, :parent => false

  before_action :set_breadcrumbs, only: [:announcer, :sign_in_sheet]

  def announcer
    add_breadcrumb "Competitor List"

    respond_to do |format|
      format.html
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

  def sign_in_sheet
    add_breadcrumb "Sign-In Sheets"
    @competitors = @competition.competitors.reorder(:lowest_member_bib_number)

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf("sign_in_sheet") }
    end
  end

  def single_attempt_recording
    @is_start_times = params[:is_start_times] && params[:is_start_times] == "true"

    @only_registered = true
    @only_registered = false if params[:only_registered].nil?

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf("single_attempt_recording") }
    end
  end

  def two_attempt_recording
    @is_start_times = params[:is_start_times] && params[:is_start_times] == "true"

    @only_registered = true
    @only_registered = false if params[:only_registered].nil?

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf("two_attempt_recording") }
    end
  end

  def results
    name = "#{@config.short_name.tr(" ", "_")}_#{@competition.name.tr(" ", "_")}_results"
    attachment = true unless params[:attachment].nil?

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf(name, "Portrait", attachment) }
    end
  end

  private

  def load_competition
    @competition = Competition.find(params[:id])
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end
end

