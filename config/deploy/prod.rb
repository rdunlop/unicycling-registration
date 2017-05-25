set :deploy_to, '/home/ec2-user/unicycling-registration'
set :rails_env, 'production'
set :branch, 'fix_cap_deploytags'

server '54.148.245.79', user: 'ec2-user', roles: %w(web app db)
