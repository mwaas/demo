resource_name :demo_unpack

property :command, String, default: 'tar -xzf'
property :source_dir_url, String, required: true
property :package_name, String, required: true
property :target_dir, String, required: true
property :runas_user, String, default: 'root'
property :runas_group, String, default: 'root'
property :change_user, String, default: 'root'
property :change_group, String, default: 'root'
property :change_mode, String, default: '0770'
property :force_download, [TrueClass, FalseClass], default: false
property :force_unpack, [TrueClass, FalseClass], default: false

load_current_value do
  full_source_url "#{source_dir_url}/#{package_name}";
  temp_file "#{Chef::Config[:file_cache_path]}/#{package_name}";
end

default_action :unpack

action :unpack do
  file temp_file do
    action :delete
    only_if { force_download }
  end
  
  directory target_dir do
    action :delete
    only_if { force_unpack }
  end

  remote_file "Download source file from #{full_source_url} into #{temp_file}"  do
    path temp_file
    source full_source_url
    retries 30
    retry_delay 10
    not_if "File.exist?(#{temp_file})"
  end

  execute "Unpack #{temp_file} into #{target_dir}" do
    user runas_user
    group runas_group
    command "#{command} #{temp_file} -C #{target_dir}"
    not_if "File.exist?(#{target_dir})"
  end

  execute "Change all file and directory ownership recursively for #{target_dir}" do
    command "chown -R #{change_user}:#{change_group} #{target_dir}"
    only_if { property_is_set?(:change_user) || property_is_set?(:change_group) }
  end

  execute "Change all file and directory mode recursively for #{target_dir}" do
    command "chmod -R #{change_mode} #{target_dir}"
    only_if { property_is_set?(:change_mode) }
  end
end

