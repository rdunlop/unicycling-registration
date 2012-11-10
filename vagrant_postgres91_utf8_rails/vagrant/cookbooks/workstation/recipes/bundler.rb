
execute "install bundler" do
  command "gem install bundler --no-rdoc --no-ri"
  ignore_failure false
  not_if "bundle -v 2>/dev/null"
end
