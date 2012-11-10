
execute "create and migrate db" do
  command "cd /home/vagrant/workspace && rake db:create && rake db:migrate"
  ignore_failure false
end
