set :deploy_to, '/home/ec2-user/unicycling-registration'
set :rails_env, 'production'
set :branch, ENV["CIRCLE_SHA1"] || ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

server '54.148.245.79', user: 'ec2-user', roles: %w[web app db]
