# Allows you to only run specific types of tests
#
# bundle exec rake spec:unit
# bundle exec rake spec:integration
# bundle exec rake spec:api

namespace :spec do
  Rspec::Core::RakeTask.new(:unit) do |t|
    t.pattern = Dir['spec/*/**/*_spec.rb'].reject{ |f| f['/api/v1'] || f['/integration'] }
  end

  Rspec::Core::RakeTask.new(:api) do |t|
    t.pattern = "spec/*/{api/v1}*/**/*_spec.rb"
  end

  Rspec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "spec/integration/**/*_spec.rb"
  end
end
