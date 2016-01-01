require 'optparse'
require 'yaml'
require "erb"

options = {}
options[:config_file] = "certs.yml"
options[:webroot_path] = "/home/ec2-user/unicycling-registration/current/public"
options[:base_domain] = "regtest.unicycling-software.com"
options[:socket_path] = "/tmp/unicorn-unicycling-registration.socket"
options[:include_ssl] = true
LETSENCRYPT_CONFIG = "/etc/letsencrypt/cli.ini"
NGINX_CONFIG = "/etc/nginx/conf.d/registration.conf"

OptionParser.new do |opts|
  opts.banner = "Usage: renew_certs.rb [options]"

  opts.on('-c', '--config FILE', "Config File Listing domains (default #{options[:config_file]})") { |v| options[:config_file] = v }
  opts.on('-r', '--really', 'Really Run command') { |_v| options[:really_run] = true }
  opts.on('-p', '--production', 'Run against production cert server') { |_v| options[:production] = true }
  opts.on('-u', '--update', 'Update the letsencrypt configuration file') { |_v| options[:update] = true }
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
  return 1
end

# Repeat the "-d domain name" block as many times as necessary.
CMD = "/home/ec2-user/letsencrypt/letsencrypt-auto"

command = "#{CMD} certonly"

puts "Command:"
puts command

def update_config(_config, _options)
  template = %q(
# This is an example of the kind of things you can do in a configuration file.
# All flags used by the client can be configured here. Run Let's Encrypt with
# "--help" to learn more about the available options.

# Use a 4096 bit RSA key instead of 2048
# rsa-key-size = 4096

# Because Amazon Linux isn't fully supported
debug = True

# to see progress/errors
verbose = True

# Because my e-mail address isn't permitted by letsencrypt
register-unsafely-without-email = True

# To prevent command-line prompt
agree-tos = True

<% unless options[:production] %>
# Always use the staging/testing server
staging = True
<% end %>

# Because we will often be adding domains to the list
renew-by-default = True

# Uncomment and update to register with the specified e-mail address
# email = foo@example.com

# Uncomment and update to generate certificates for the specified
# domains.
# domains = example.com, www.example.com
domains = <%= config[:domains].join(", ") %>

# Uncomment to use a text interface instead of ncurses
text = True

# Uncomment to use the standalone authenticator on port 443
# authenticator = standalone
# standalone-supported-challenges = tls-sni-01

# Uncomment to use the webroot authenticator. Replace webroot-path with the
# path to the public_html / webroot folder being served by your web server.
authenticator = webroot
webroot-path = <%= options[:webroot_path] %>
)
  bytes_written = File.write(LETSENCRYPT_CONFIG, ERB.new(template).result())
end

def update_nginx_config(config, options)
  if options[:include_ssl]
    @first_domain = config[:domains].first
  end

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
    server_name *.<%= options[:base_domain] %>;

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
    ssl on;

    ssl_certificate /etc/letsencrypt/live/<%= @first_domain %>/cert.pem;
    ssl_certificate_key /etc/letsencrypt/live/<%= @first_domain %>/privkey.pem;

    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/<%= @first_domain %>/fullchain.pem;

    ssl_session_timeout 5m;
    <% end %>
}
'
  bytes_written = File.write(NGINX_CONFIG, ERB.new(template).result())
end

def load_config(options)
  config = YAML.load_file(options[:config_file])

  unless config[:domains]
    puts "Config file should contain list of domains like:"
    puts "---"
    puts ":domains:"
    puts "- hello"
    puts "- goodbye"
    puts
    return 1
  end
  config
end

if options[:update]
  config = load_config(options)
  puts "Writing to #{LETSENCRYPT_CONFIG}"
  update_config(config, options)
end

if options[:update_nginx]
  config = {}
  config = load_config(options) if options[:include_ssl]
  puts "Writing to #{NGINX_CONFIG}"
  update_nginx_config(config, options)
end

if options[:really_run]
  puts "running command against cert server"
  result = `#{command}`
  puts "result is #{result}"
end

exit(0)
