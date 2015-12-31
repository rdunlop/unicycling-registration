set :deploy_to, '/home/ec2-user/unicycling-registrationtest'
set :rails_env, 'stage'
set :branch, ENV['BRANCH'] || 'master'

server '52.32.67.36', user: 'ec2-user', roles: %w(web app db)
