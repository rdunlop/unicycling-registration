set :deploy_to, '/home/ec2-user/unicycling-registration'
set :rails_env, 'stage'
set :branch, ENV["CIRCLE_SHA1"] || ENV["REVISION"] || ENV["BRANCH_NAME"] || "main"

server '44.244.255.187', user: 'ec2-user', roles: %w[web app db] # CNAME to the single stage server
