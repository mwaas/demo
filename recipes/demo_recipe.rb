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

log 'Calling demo_check_prerequisite' do
  level :info
end

demo_check_prerequisite;

log 'Calling demo_definition' do
  level :info
end

demo_definition;

log 'Calling demo_unpack custom resource' do
  level :info
end

demo_unpack 'Unpack zip file' do
  command 'tar -xzf'
  source_dir_url 'file:///data/mwaas/images'
  package_name 'demo_pack.tar.gz'
  target_dir '/tmp/demo/unpack'
  runas_user "#{userid}"
  runas_group "#{userid}"
  change_user "#{userid}"
  change_group "#{userid}"
  change_mode '0770'
  force_download false
  force_unpack false
end

demo_databag1_node = data_bag_item('demo_data_bags', 'demo_databag1');
puts "fieldA in demo_data_bags/demo_databag1.json is " + demo_databag1_node['fieldA']
puts "fieldB in demo_data_bags/demo_databag1.json is " + demo_databag1_node['fieldB']

cookbook_file '/tmp/demo/file_from_demo_file.txt' do
  source 'demo_file.txt'
  owner "#{userid}"
  group "#{userid}"
  mode '0664'
  action :create
end

log 'Exiting demo_recipe' do
  level :info
end

