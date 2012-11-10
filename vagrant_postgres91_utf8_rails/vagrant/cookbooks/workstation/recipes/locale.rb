cookbook_file '/etc/default/locale' do
  owner 'root'
  group 'root'
  mode 0644
  source 'locale'
end

script 'rebuild psql cluster with UTF8 locale' do
  interpreter "bash"
  code <<-EOH
  su postgres -c 'pg_dropcluster --stop 9.1 main'
  su postgres -c 'pg_createcluster -p 5432 --start 9.1 main -e utf8'
  su postgres -c "echo \\"ALTER ROLE postgres ENCRYPTED PASSWORD '#{node[:postgresql][:password][:postgres]}';\\" | psql"
  EOH
  not_if 'su postgres -c "psql -l | grep en_US.utf8"'
end
