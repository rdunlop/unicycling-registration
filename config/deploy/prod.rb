set :deploy_to, '/home/ec2-user/unicycling-registration'
set :rails_env, 'production'
set :branch, 'master'

server '54.148.148.88', user: 'ec2-user', roles: %w(web app db)
