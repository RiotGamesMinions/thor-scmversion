require 'securerandom'

Given /^I have a git project of version '(.*)'$/ do |version|
  Dir.chdir(origin_dir) do
    `git init`
    $?.success?.should be_true
    `git config receive.denyCurrentBranch ignore`
    $?.success?.should be_true
  end
  Dir.chdir(project_dir) do
    `git clone file://#{origin_dir}/.git .`
    $?.success?.should be_true
    `touch README`
    $?.success?.should be_true
    `git add README`
    $?.success?.should be_true
    `git commit -m "initial commit"`
    $?.success?.should be_true
    `git tag -a -m "Version #{version}" #{version}`
    $?.success?.should be_true
    `git push origin master -u --tags`
    $?.success?.should be_true
    setup_directory
  end
end

Given /^a commit with the message "(.*?)" on the "(.*?)" branch$/ do |msg, branch|
  Dir.chdir(project_dir) do
    `echo #{SecureRandom.uuid} > Randomfile`
    `git add Randomfile`
    `git commit -m "#{msg}"`
    `git push origin #{branch}`
  end
end

Then /^the version should be '(.*)'$/ do |version|
  Dir.chdir(project_dir) {
    ThorSCMVersion.versioner.from_path.to_s.should == version
  }
end

Then /^the version should be '(.+)' in the p4 project directory$/ do |version|
  Dir.chdir(perforce_project_dir) {
    ThorSCMVersion.versioner.from_path.to_s.should == version
  }
end

Then /^the git server version should be '(.*)'$/ do |version|
  Dir.chdir(origin_dir) {
    ThorSCMVersion.versioner.from_path.to_s.should == version
  }
end

Given /^the origin version is '(.+)'$/ do |version|
  Dir.chdir(origin_dir) {
    cmd = %Q[git tag -a #{version} -m "Version #{version}"]
    `#{cmd}`
  }  
end

When /^I run `(.*)` from the temp directory( and expect a non-zero exit)?$/ do |command, nonzero_exit|
  Dir.chdir(project_dir) {
    out = `#{command}`
    unless $?.success? or nonzero_exit
      puts out
      fail
    end
  }
end

When /^I run `(.*)` from the p4 project directory$/ do |run|
  Dir.chdir(perforce_project_dir) {
    `#{run}`
  }
end

Given /^I have a p4 project of version '(.*)'$/ do |version|
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

Then(/^there is a version '(.+)' on another branch$/) do |version|
  Dir.chdir(project_dir) do
    `git checkout -b another_branch`
    $?.success?.should be_true
    `echo anotherbranch > README`
    $?.success?.should be_true
    `git commit -am 'commit'`
    $?.success?.should be_true
    `git tag #{version}`
    $?.success?.should be_true
    `git checkout master`
    $?.success?.should be_true
  end
end

Given(/^there is a tag '(.*)'$/) do |version|
  Dir.chdir(project_dir) do
    `git tag #{version}`
  end
end

Given(/^.git is a file pointing to the .git folder in a parent module$/) do
  project_git_path = File.join(project_dir, '.git')
  git_folder_path  = File.join(parent_module_dir, '.git')
  File.directory?( project_git_path ).should be_true
  File.rename project_git_path, git_folder_path
  `echo "gitdir: #{ git_folder_path }" > "#{ project_git_path }"`
end