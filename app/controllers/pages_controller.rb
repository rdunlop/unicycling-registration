# == Schema Information
#
# Table name: pages
#
#  id             :integer          not null, primary key
#  slug           :string           not null
#  created_at     :datetime
#  updated_at     :datetime
#  position       :integer
#  parent_page_id :integer
#
# Indexes
#
#  index_pages_on_parent_page_id_and_position  (parent_page_id,position)
#  index_pages_on_position                     (position)
#  index_pages_on_slug                         (slug) UNIQUE
#

class PagesController < ApplicationController
  before_action :skip_authorization
  layout :determine_layout_from_params

  # GET /pages/:slug
  def show
    @page = Page.find_by!(slug: params[:slug])
  end

  private

  def determine_layout_from_params
    "minimal" if params[:framed]
  end
end
