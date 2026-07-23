class LabelTypeSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_ability

  def edit
    @config = EventConfiguration.singleton
  end

  def update
    @config = EventConfiguration.singleton
    @config.enabled_label_types = Array(params[:enabled_label_types])
    @config.save!

    redirect_to user_award_labels_path(current_user), notice: 'Label type settings were successfully updated.'
  end

  private

  def authenticate_ability
    authorize current_user, :manage_awards?
  end
end
