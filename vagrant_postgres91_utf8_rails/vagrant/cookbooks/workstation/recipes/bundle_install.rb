
execute "install gems" do
  command "cd /home/vagrant/workspace && bundle install"
  ignore_failure true
end
