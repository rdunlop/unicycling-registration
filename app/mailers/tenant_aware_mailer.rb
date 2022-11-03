class TenantAwareMailer < ActionMailer::Base
  include SubdomainHelper

  helper ApplicationHelper
end
