class Admin::HistoryController < Admin::BaseController
  before_filter :authenticate_user!
  authorize_resource :class => false

  def index
    @versions = Version.all
  end
end
