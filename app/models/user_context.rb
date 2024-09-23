class UserContext
  attr_reader :user, :config, :comp_reg_closed, :noncomp_reg_closed, :reg_closed_for_limit, :authorized_laptop, :translation_domain

  def initialize(user, config, comp_reg_closed, noncomp_reg_closed, reg_closed_for_limit, authorized_laptop, translation_domain = false)
    @user = user
    @config = config
    @comp_reg_closed = comp_reg_closed
    @noncomp_reg_closed = noncomp_reg_closed
    @reg_closed_for_limit = reg_closed_for_limit
    @authorized_laptop = authorized_laptop
    @translation_domain = translation_domain
  end
end
