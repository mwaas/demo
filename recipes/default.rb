#
# Cookbook:: demo
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

log 'Running default recipe. Including recipe demo_recipe' do
  level :info
end

include_recipe 'demo::demo_recipe'

