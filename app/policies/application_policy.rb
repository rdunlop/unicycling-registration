class ApplicationPolicy
  attr_reader :user, :record, :reg_closed, :authorized_laptop
  attr_reader :config

  def initialize(user_context, record)
    if user_context.is_a?(UserContext)
      @user = user_context.user
      @config = user_context.config
      @reg_closed = user_context.reg_closed
      @authorized_laptop = user_context.authorized_laptop
    else
      # for ease of testing, we allow passing a non-user context
      # in the actual system, we will always encapsulate the user in a UserContext object
      @user = user_context
      @config = OpenStruct.new(music_submission_ended?: true)
      @reg_closed = false
      @authorized_laptop = false
    end

    raise Pundit::NotAuthorizedError, "must be logged in" unless @user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def rails_admin?(action)
    case action
    when :dashboard
      super_admin?
    when :index
      super_admin?
    when :show
      super_admin?
    when :new
      super_admin?
    when :edit
      super_admin?
    when :destroy
      super_admin?
    when :export
      super_admin?
    when :history
      super_admin?
    when :show_in_app
      super_admin?
    else
      raise ::Pundit::NotDefinedError, "unable to find policy #{action} for #{record}."
    end
  end

  private

  def late_registrant?
    user.has_role?(:late_registrant)
  end

  def data_entry_volunteer?
    user.has_role?(:data_entry_volunteer)
  end

  def membership_admin?
    user.has_role?(:membership_admin)
  end

  def music_dj?
    user.has_role?(:music_dj)
  end

  def event_planner?
    user.has_role?(:event_planner)
  end

  def payment_admin?
    user.has_role?(:payment_admin)
  end

  def translator?
    user.has_role?(:translator)
  end

  def awards_admin?
    user.has_role?(:awards_admin)
  end

  def convention_admin?
    user.has_role?(:convention_admin)
  end

  def competition_admin?
    user.has_role?(:competition_admin)
  end

  def director?(event = nil)
    user.has_role?(:director, event || :any)
  end

  def super_admin?
    user.has_role?(:super_admin)
  end

  def registration_closed?
    # Allows to modify your own records as long as you're a `late_registrant` or registration is still open
    reg_closed && !authorized_laptop && !late_registrant?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
