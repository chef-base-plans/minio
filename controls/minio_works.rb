title 'Tests to confirm minio works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'minio')

control 'core-plans-minio-works' do
  impact 1.0
  title 'Ensure minio works as expected'
  desc '
  Verify minio by ensuring 
  (1) its installation directory exists and 
  (2) that it returns the expected version.  Since minio --help returns a version
  like "2019-07-31T18:57:56Z" with colons but the plan_pkg_version (derived from the plan_pkg_ident)
  only contains hyphens "-", then logical equivalence is achieved by transforming 
  plan_pkg_version ==> minio_version_with_colons below
  '
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end
  
  plan_pkg_ident = ((plan_installation_directory.stdout.strip).match /(?<=pkgs\/)(.*)/)[1]
  plan_pkg_version = (plan_pkg_ident.match /^#{plan_origin}\/#{plan_name}\/(?<version>.*)\//)[:version]
  version_element = plan_pkg_version.split("-")
  minio_version_with_colons = "#{version_element[0]}-#{version_element[1]}-#{version_element[2]}:#{version_element[3]}:#{version_element[4]}"
  describe command("DEBUG=true; hab pkg exec #{plan_pkg_ident} minio --help") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /#{minio_version_with_colons}/ }
    its('stderr') { should be_empty }
  end
end