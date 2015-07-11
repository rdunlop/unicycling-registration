class UserContext
  attr_reader :user, :reg_closed, :authorized_laptop

  def initialize(user, reg_closed, authorized_laptop)
    @user = user
    @reg_closed = reg_closed
    @authorized_laptop = authorized_laptop
  end
end
