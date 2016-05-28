class WelcomeController < ApplicationController
  before_action :authenticate_user!, only: [:data_entry_menu]
  before_action :skip_authorization, except: [:data_entry_menu]

  before_action :check_acceptable_format

  def help_translate
  end

  def help
    @user = current_user
  end

  # GET /welcome/usa_membership
  def usa_membership
  end

  # GET /welcome/changelog
  def changelog
  end

  # GET /welcome/confirm
  # The path where users are directed after signing up
  def confirm
  end

  # This is the "root_path", and redirects the user to different places
  # depending on the configuration of the server.
  def index
    flash.keep
    # if this is the translation domain, put the user on the translation-instructions page
    if translation_domain?
      authenticate_user!
      if user_signed_in?
        redirect_to translations_path
        return
      end
    end

    if unmatched_tenant?
      flash[:notice] = "Please choose a valid registration domain"
      redirect_to tenants_path
      return
    end

    # if we have a "home" page, show them that
    if Page.exists?(slug: "home")
      redirect_to page_path("home")
    else
      authenticate_user!
      if user_signed_in?
        redirect_to user_registrants_path(current_user)
      end
    end
  end

  def data_entry_menu
    authorize current_user, :view_data_entry_menu?
    @judges = current_user.judges.joins(:competition).merge(Competition.order(scheduled_completion_at: :desc))
    @director_events = Event.with_role(:director, current_user).order(:name)
  end

  private

  # This tries to get around the apple-touch-icon.png requests
  #  and the humans.txt requests
  def check_acceptable_format
    if ["txt", "png"].include?(params[:format])
      params[:format] = nil
      raise ActiveRecord::RecordNotFound.new
    end
  end
end
