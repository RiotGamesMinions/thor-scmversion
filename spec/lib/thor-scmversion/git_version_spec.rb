require 'spec_helper'

module ThorSCMVersion
  describe GitVersion do
    it "should detect if a commit is contained on a given branch" do
      ShellUtils.stub(:sh).and_return(<<OUT)
* constrain_bump_to_branch
  master
OUT
      expect(GitVersion.contained_in_current_branch?('0.0.1')).to be_true
    end
  end
end
