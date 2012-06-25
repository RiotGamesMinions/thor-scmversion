Given /^I have a git project of version '(.*)'$/ do |version|
  Dir.chdir(origin_dir) do
    `git init`
  end
  Dir.chdir(project_dir) do
    `git init`
    `touch README`
    `git add README`
    `git commit -m "initial commit"`
    `git tag -a -m "Version #{version}" #{version}`
    `git remote add origin file://#{origin_dir}`
    setup_directory
  end
end

Then /^the version should be '(.*)'$/ do |version|
  Dir.chdir(project_dir) {
    ThorSCMVersion.versioner.from_path.to_s.should == version
  }
end

Then /^the version should be '(.+)' in the Perforce project directory$/ do |version|
  Dir.chdir(perforce_project_dir) {
    ThorSCMVersion.versioner.from_path.to_s.should == version
  }
end

Then /^the origin version should be '(.*)'$/ do |version|
  Dir.chdir(origin_dir) {
    ThorSCMVersion.versioner.from_path.to_s.should == version
  }
end

When /^I run `(.*)` from the temp directory$/ do |run|
  Dir.chdir(project_dir) {
    `#{run}`
  }
end

When /^I run `(.*)` from the Perforce project directory$/ do |run|
  Dir.chdir(perforce_project_dir) {
    `#{run}`
  }
end

Given /^I have a Perforce project of version '(.*)'$/ do |version|
  ENV['P4PORT']    = 'p4server.example.com:1666'
  ENV['P4USER']    = 'tester'
  ENV['P4PASSWD']  = 'tester'
  ENV['P4CHARSET'] = ''
  ENV['P4CLIENT']  = 'testers_workspace'
  Dir.chdir(perforce_project_dir) do
    ThorSCMVersion::Perforce.connection do
      `p4 sync -f`
    end
    File.chmod(0666,"VERSION")
    File.open('VERSION', 'w') do |f|
      f.write(version)
    end
    setup_directory
  end
end

Then /^the p4 server version should be '(.*)'$/ do |version|
  ENV['P4PORT']    = 'p4server.example.com:1666'
  ENV['P4USER']    = 'tester'
  ENV['P4PASSWD']  = 'tester'
  ENV['P4CHARSET'] = ''
  ENV['P4CLIENT']  = 'testers_workspace'
  Dir.chdir(perforce_project_dir) do
    ThorSCMVersion::Perforce.connection do
      `p4 print #{File.join(perforce_project_dir,'VERSION')}`
      #p4.run_print(File.join(perforce_project_dir,'VERSION'))[1].should == version
    end
  end
end
