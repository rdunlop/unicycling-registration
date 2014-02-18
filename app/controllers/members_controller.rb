class MembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_competitor, :only => [:create]
  before_filter :load_member, :only => [:destroy]
  before_filter :load_new_member, :only => [:create]
  load_and_authorize_resource

  private
  def load_competitor
    @competitor = Competitor.find(params[:competitor_id])
  end

  def load_member
    @member = Member.find(params[:id])
  end

  def load_new_member
    @member = Member.new(:registrant_id => params[:registrant_id], :competitor_id => params[:competitor_id])
  end

  public
  # POST /competitors/3/members
  def create

    respond_to do |format|
      if @member.save
        format.html { redirect_to edit_competitor_path(@competitor), notice: 'Member created.' }
      else
        format.html { redirect_to edit_competitor_path(@competitor), alert: 'Member failed.' }
      end
    end
  end

  # DELETE /members/1
  def destroy
    competitor = @member.competitor
    @member.destroy

    respond_to do |format|
      format.html { redirect_to edit_competitor_path(competitor) }
      format.json { head :no_content }
    end
  end

  private
  def member_path
    params.require(:member).permit(:competitor_id, :registrant_id)
  end
end
