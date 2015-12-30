# == Schema Information
#
# Table name: event_categories
#
#  id                              :integer          not null, primary key
#  event_id                        :integer
#  position                        :integer
#  name                            :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  age_range_start                 :integer          default(0)
#  age_range_end                   :integer          default(100)
#  warning_on_registration_summary :boolean          default(FALSE), not null
#
# Indexes
#
#  index_event_categories_event_id              (event_id,position)
#  index_event_categories_on_event_id_and_name  (event_id,name) UNIQUE
#

class EventCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumb, only: [:sign_ups]

  respond_to :html

  def sign_ups
    @event_category = EventCategory.find(params[:id])
    authorize @event_category
    add_breadcrumb "#{@event_category} Sign-Ups"

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf "show" }
    end
  end

  private

  def set_breadcrumb
    add_breadcrumb "Events Report", summary_events_path
  end
end
