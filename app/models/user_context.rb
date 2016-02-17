class UserContext
  attr_reader :user, :config, :reg_closed, :authorized_laptop, :translation_domain

  def initialize(user, config, reg_closed, authorized_laptop, translation_domain = false)
    @user = user
    @config = config
    @reg_closed = reg_closed
    @authorized_laptop = authorized_laptop
    @translation_domain = translation_domain
  end
end
