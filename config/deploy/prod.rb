set :deploy_to, '/home/ec2-user/unicycling-registration'
set :rails_env, 'production'
set :branch, ENV["CIRCLE_SHA1"] || ENV["REVISION"] || ENV["BRANCH_NAME"] || "main"

server '35.90.235.116', user: 'ec2-user', roles: %w[web app db] # CNAME to the single prod server
