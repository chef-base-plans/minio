title 'Tests to confirm minio exists'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'minio')
command_relative_path = input('command_relative_path', value: 'bin/minio')

control 'core-plans-minio-exists' do
  impact 1.0
  title 'Ensure minio exists'
  desc '
  Verify minio by ensuring /bin/minio exists'
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end

  command_full_path = File.join(plan_installation_directory.stdout.strip, "#{command_relative_path}")
  describe file(command_full_path) do
    it { should exist }
  end
end
