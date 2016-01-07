class Admin::TranslationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_setup, except: [:clear_cache]
  before_action :add_breadcrumbs

  def index
  end

  def clear_cache
    authorize :translation, :clear_cache?
    clear_cache_i18n
    flash[:notice] = "Translation Cache cleared"
    redirect_to translations_path
  end

  private

  def authorize_setup
    authorize :translation, :index?
  end

  def add_breadcrumbs
    add_breadcrumb "Translations", translations_path
  end
end
