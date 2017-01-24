log 'Running demo_recipe' do
  level :info
end

userid = node['demo']['user_id'];
username = node['demo']['user_name'];

user "Create user #{userid} for #{username}" do
  username "#{userid}"
  home "/home/#{userid}"
  shell '/bin/bash'
  manage_home true
  action :create
end

directory '/tmp/demo' do
  owner "#{userid}"
  group "#{userid}"
  mode '0775'
  action :create
end

log 'Calling demo_definition' do
  level :info
end

demo_definition;

log 'Calling demo_unpack custom resource' do
  level :info
end

demo_unpack 'Unpack zip file' do
#  command 'tar -xzf'
  source_dir_url 'file:///mwaas/temp'
  package_name 'demo_pack.zip'
  target_dir '/tmp/demo'
#  runas_user 'root'
#  runas_group 'root'
#  change_user 'root'
#  change_group 'root'
#  change_mode '0770'
  force_download false
  force_unpack false
end

