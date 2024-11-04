set :deploy_to, '/home/ec2-user/unicycling-registration'
set :rails_env, 'production'
set :branch, ENV["CIRCLE_SHA1"] || ENV["REVISION"] || ENV["BRANCH_NAME"] || "main"

server 'registration.unicycling-software.com', user: 'ec2-user', roles: %w[web app db] # CNAME to the single prod server
