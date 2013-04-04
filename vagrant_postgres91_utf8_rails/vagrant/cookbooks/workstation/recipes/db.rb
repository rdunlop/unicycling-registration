
execute "create and migrate db" do
  command "cd /home/vagrant/workspace && rake db:create && rake db:migrate"
  ignore_failure false
end
execute "create and populate db in TEST" do
  command "cd /home/vagrant/workspace && RAILS_ENV=test rake db:create && rake db:test:prepare"
  ignore_failure false
end
