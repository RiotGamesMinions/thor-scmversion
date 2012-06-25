require 'aruba/cucumber'
require 'tmpdir'

$:.push "#{File.dirname(__FILE__)}/../../lib/"
require 'rspec'
require 'thor-scmversion'

def project_dir
  @tmpdir ||= Dir.mktmpdir
end

def perforce_project_dir
  dir = "/temp/p4sandbox/artifact"
  FileUtils.mkdir_p dir
  dir
end

def origin_dir
  @origindir ||= Dir.mktmpdir
end

def fixtures_dir
  File.join(File.dirname(__FILE__), "..", "fixtures")
end

def app_root
  File.join(File.dirname(__FILE__), '..', '..')
end

def setup_directory
File.open('Gemfile', 'w') do |f|
  f.write "gem 'thor-scmversion', path: '#{app_root}'"
  end
  `bundle`
  Dir.entries(fixtures_dir).each do |entry|
  FileUtils.cp_r(File.join(fixtures_dir, entry), '.')
  end
end

After do |scenario|
   FileUtils.rm_rf(project_dir)
   FileUtils.rm_rf(origin_dir)
end

After('@p4') do |scenario|
  ENV['P4PORT']    = 'p4server.example.com:1666'
  ENV['P4USER']    = 'tester'
  ENV['P4PASSWD']  = 'tester'
  ENV['P4CHARSET'] = ''
  ENV['P4CLIENT']  = 'testers_workspace'
  Dir.chdir(perforce_project_dir) do
    ThorSCMVersion::Perforce.connection do
      #p4.run_sync("-f")
      `p4 sync -f`
      description = "Bump version to #{to_s}."
      `p4 edit -c default #{File.join(perforce_project_dir, "VERSION")}`
      File.open(File.join(perforce_project_dir, "VERSION"), 'w') { |f| f.write '1.0.0' }
      `p4 submit -d \"#{description}\"`
      #new_changelist = p4.fetch_change
      #new_changelist._Description = "Reseting version to 1.0.0 for next test."
      #saved_changelist = p4.save_change(new_changelist)
      #changelist_number = saved_changelist[0].match(/(\d+)/).to_s.strip
      #p4.run_edit("-c", changelist_number, File.join(perforce_project_dir, "VERSION"))

      #File.open(File.join(perforce_project_dir, "VERSION"), 'w') { |f| f.write '1.0.0' }
      #changelist = p4.fetch_change changelist_number
      #p4.run_submit changelist
    end
  end
end
