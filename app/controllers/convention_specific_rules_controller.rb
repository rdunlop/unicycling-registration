class ConventionSpecificRulesController < ApplicationController
  before_action :skip_authorization

  # redirect to s3 file, so that the link doesn't expire
  def show
    raise ActiveRecord::RecordNotFound unless @config.rules_file_name?

    redirect_to @config.rules_file_name_url
  end
end
