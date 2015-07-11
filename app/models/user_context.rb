class UserContext
  attr_reader :user, :config, :reg_closed, :authorized_laptop

  def initialize(user, config, reg_closed, authorized_laptop)
    @user = user
    @config = config
    @reg_closed = reg_closed
    @authorized_laptop = authorized_laptop
  end
end
