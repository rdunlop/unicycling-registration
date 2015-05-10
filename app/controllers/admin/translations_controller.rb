class Admin::TranslationsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource :translation, class: false
  before_action :add_breadcrumbs

  def index
  end

  def clear_cache
    clear_cache_i18n
    flash[:notice] = "Translation Cache cleared"
    redirect_to translations_path
  end

  private

  def add_breadcrumbs
    add_breadcrumb "Translations", translations_path
  end
end
