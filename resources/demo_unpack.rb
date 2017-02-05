resource_name :demo_unpack

property :command, String, default: 'tar -xzf'
property :source_dir_url, String, required: true
property :package_name, String, required: true
property :target_dir, String, required: true
property :runas_user, String, default: 'root'
property :runas_group, String, default: 'root'
property :change_user, String
property :change_group, String
property :change_mode, String
property :force_download, [TrueClass, FalseClass], default: false
property :force_unpack, [TrueClass, FalseClass], default: false

full_source_url = 'full_source_url_initialized';
temp_file = 'temp_file_initialized';
change_user = 'change_user_initialized';
change_group = 'change_group_initialized';
change_mode = 'change_mode_initialized';
force_download = false;
force_unpack = false;
 
load_current_value do |desired|
  full_source_url = "#{desired.source_dir_url}/#{desired.package_name}";
  puts "\nfull_source_url is #{full_source_url}";

  temp_file = "#{Chef::Config[:file_cache_path]}/#{desired.package_name}";
  puts "temp_file is #{temp_file}";

  change_user = desired.change_user;
  if change_user == nil
    puts "change_user is nil";
  else
    puts "change_user is #{change_user}";
  end

  change_group = desired.change_group;
  if change_group == nil
    puts "change_group is nil";
  else
    puts "change_group is #{change_group}";
  end

  change_mode = desired.change_mode;
  if change_mode == nil
    puts "change_mode is nil";
  else
    puts "change_mode is #{change_mode}";
  end

  force_download = desired.force_download;
  puts "force_download is #{force_download}";

  force_unpack = desired.force_unpack;
  puts "force_unpack is #{force_unpack}";
end

default_action :unpack

action :unpack do
  log "Delete temp_file #{temp_file} if force_download is true" do
    level :info
  end

  file temp_file do
    action :delete
    only_if { force_download }
  end
  
  log "Delete target_dir #{target_dir} if force_unpack is true" do
    level :info
  end

#  directory target_dir do
#    action :delete
#    recursive true
#    only_if { force_unpack }
#  end
#Deleting and recreating same directory is considered resource cloning and is deprecated in Chef - so use execute resource instead
  execute "Delete target_dir #{target_dir} if force_unpack is true" do
    command "rm -r #{target_dir}"
    only_if { force_unpack && Dir.exist?(target_dir)}
  end

  log "Create target_dir #{target_dir} if it does not exist" do
    level :info
  end

  directory target_dir do
    owner runas_user
    group runas_group
    action :create
  end

  remote_file "Download source file from #{full_source_url} into #{temp_file}"  do
    path temp_file
    source full_source_url
    retries 30
    retry_delay 10
    not_if "File.exist?(#{temp_file})"
  end

  puts "checking #{target_dir}"
  if Dir.exist?(target_dir)
    puts "number of entries for #{target_dir} is " + Dir.entries(target_dir).size.to_s
    puts "entries for #{target_dir} are \n" + Dir.entries(target_dir).to_s

    if Dir.entries(target_dir).size == 2
      puts "#{target_dir} is empty"
    else
      puts "#{target_dir} is not empty"
    end
  else
    puts "#{target_dir} does not exist"
  end

  execute "Unpack #{temp_file} into #{target_dir}" do
    user runas_user
    group runas_group
    command "#{new_resource.command} #{temp_file} -C #{target_dir}"
    only_if { force_unpack  || Dir.entries(target_dir).size == 2 }
  end

  execute "Change all file and directory ownership recursively for #{target_dir}" do
    command "chown -R #{change_user}:#{change_group} #{target_dir}"
#    only_if { property_is_set?(:change_user) || property_is_set?(:change_group) }
    not_if { (change_user == nil) || (change_group == nil) }
  end

  execute "Change all file and directory mode recursively for #{target_dir}" do
    command "chmod -R #{change_mode} #{target_dir}"
#    only_if { property_is_set?(:change_mode) }
    not_if { change_mode == nil }
  end
end

