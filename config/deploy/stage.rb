set :deploy_to, '/home/ec2-user/unicycling-registration'
set :rails_env, 'stage'
set :branch, ENV['BRANCH'] || 'develop'

server 'regtest.unicycling-software.com', user: 'ec2-user', roles: %w[web app db]

set :no_deploytags, true
