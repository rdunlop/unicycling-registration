class TenantAwareMailer < ActionMailer::Base
  include SubdomainHelper

  add_template_helper(ApplicationHelper)
end
