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

