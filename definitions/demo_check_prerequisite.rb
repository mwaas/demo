define :demo_check_prerequisite do
  log 'running demo_check_prerequisite' do
    level :info
  end

  ruby_block 'Verify image repository' do
    block do
      raise 'Image repository is missing' if !File.exist?('/mwaas/images')
    end
  end
end

