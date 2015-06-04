Then(/^there is a tag of version '(.+)' on the git server$/) do |version|
  Dir.chdir(origin_dir) do
    `git tag #{version}`
    $?.success?.should be true
  end
end
