# == Schema Information
#
# Table name: published_age_group_entries
#
#  id                 :integer          not null, primary key
#  competition_id     :integer
#  age_group_entry_id :integer
#  published_at       :datetime
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_published_age_group_entries_on_competition_id  (competition_id)
#

class PublishedAgeGroupEntriesController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :skip_authorization, only: :show

  before_action :load_competition

  respond_to :html

  def show
    @published_age_group_entry = PublishedAgeGroupEntry.find(params[:id])
    @ag_entry = @published_age_group_entry.age_group_entry
    @results_list = @competition.results_list_for(@ag_entry)

    name = "#{@competition} {@ag_entry}"
    attachment = false

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf(name, "Portrait", attachment) }
    end
  end

  def preview
    authorize @competition, :publish_age_group_entry?
    @ag_entry = AgeGroupEntry.find(params[:id])
    @results_list = @competition.results_list_for(@ag_entry)
    respond_to do |format|
      format.html { render :show }
      format.pdf { render_common_pdf("preview") }
    end
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end
end
