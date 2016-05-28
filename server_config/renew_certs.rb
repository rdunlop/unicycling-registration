require 'optparse'
require 'yaml'
require "erb"

options = {}
options[:webroot_path] = "/home/ec2-user/unicycling-registration/current/public"
options[:base_domain] = "regtest.unicycling-software.com"
options[:socket_path] = "/tmp/unicorn-unicycling-registration.socket"
options[:include_ssl] = true
NGINX_CONFIG = "/etc/nginx/conf.d/registration.conf".freeze

OptionParser.new do |opts|
  opts.banner = "Usage: renew_certs.rb [options]"

  opts.on('-b', '--no-ssl', 'Create nginx configuration WITHOUT SSL') { |_v| options[:include_ssl] = false }
  opts.on('-n', '--update-nginx', 'Update the nginx configuration file') { |_v| options[:update_nginx] = true }
  opts.on('-d', '--domain DOMAIN', "Base Domain path (default: #{options[:base_domain]})") { |v| options[:base_domain] = v }
  opts.on('-s', '--socket SOCKET_PATH', "Unix Socket path for Unicorn (default: #{options[:socket_path]})") { |v| options[:socket_path] = v }
  opts.on('-w', '--webroot WEB_ROOT_PATH', "Webroot Path (default #{options[:webroot_path]})") { |v| options[:webroot_path] = v }
end.parse!

puts "----------------"
puts "OPTIONS:"
puts options
puts "----------------"

unless File.exist?(options[:webroot_path])
  puts "Webroot path #{options[:webroot_path]} Not found"
  exit(1)
end

# "options" IS used, by ERB
def update_nginx_config(options) # rubocop:disable Lint/UnusedMethodArgument
  template = '
#
# A virtual host using mix of IP-, name-, and port-based configuration
#

upstream regapp {
    # Path to Unicorn SOCK file, as defined previously
    server unix:<%= options[:socket_path] %> fail_timeout=0;
}

server {

    # FOR HTTPS
    listen 80;
    # server_name registrationtest.regtest.unicycling-software.com;

    # FOR HTTP:
    # listen 80 default_server;
    server_name *.<%= options[:base_domain] %> <%= options[:base_domain] %>;

    gzip on;

    # Application root, as defined previously
    root <%= options[:webroot_path] %>;

    try_files $uri/index.html $uri @regapp;

    location @regapp {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://regapp;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;

    # BELOW THIS LINE FOR HTTPS
    <% if options[:include_ssl] %>
    listen 443 default_server ssl;

    # The following should be enabled once everything is SSL
    # ssl on;

    ssl_certificate <%= options[:webroot_path] %>/system/cert.pem;
    ssl_certificate_key <%= options[:webroot_path] %>/system/privkey.pem;

    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate <%= options[:webroot_path] %>/system/fullchain.pem;

    ssl_session_timeout 5m;
    <% end %>
}
'
  result = ERB.new(template).result()

  puts "START NGINX_CONFIG -----------------"
  puts result
  puts "END NGINX_CONFIG -----------------"

  File.write(NGINX_CONFIG, result)
end

if options[:update_nginx]
  puts "Writing to #{NGINX_CONFIG}"
  update_nginx_config(options)
end

exit(0)
