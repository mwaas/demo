define :demo_definition do
  log 'running demo_definition' do
    level :info
  end

  userid = node['demo']['user_id'];
  username = node['demo']['user_name'];
  
  template '/tmp/demo/helloWorld.txt' do
    owner "#{userid}"
    group "#{userid}"
    mode '0664'
    source 'demo_template.erb'
    variables({
      :param1 => 'value1',
      :param2 => 'value2'
    })
  end

end

