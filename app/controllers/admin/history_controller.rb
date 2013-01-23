class Admin::HistoryController < Admin::BaseController
  before_filter :authenticate_user!
  skip_authorization_check # XXX because I'm using the BaseController for auth

  def index
    @versions = Version.all
  end
end
