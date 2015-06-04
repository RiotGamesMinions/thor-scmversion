Given /^I have a git project with VERSION file of version '(.*)'$/ do |version|
  Dir.chdir(origin_dir) do
    `git init`
    $?.success?.should be true
    `git config receive.denyCurrentBranch ignore`
    $?.success?.should be true
  end
  Dir.chdir(project_dir) do
    `git clone file://#{origin_dir}/.git .`
    $?.success?.should be true
    `touch README`
    $?.success?.should be true
    `git add README`
    $?.success?.should be true
    `git commit -m "initial commit"`
    $?.success?.should be true
    `git tag 0.0.1`
    $?.success?.should be true
    `git push origin master -u --tags`
    $?.success?.should be true
    setup_directory
    `echo #{version} > VERSION`
    $?.success?.should be true
  end
end
Given /^I have a p4 project with VERSION file of version '(.*)'$/ do |version|
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
    `echo #{version} > VERSION`
    $?.success?.should be true
  end
end
Then /^the VERSION file should be '(.*)'$/ do |version|
  Dir.chdir(project_dir) {
    ThorSCMVersion.versioner.from_file.to_s.should == version
  }
end
