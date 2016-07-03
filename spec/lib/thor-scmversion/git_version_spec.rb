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

    describe '::latest_from_path' do
      it 'returns the latest tag' do
        Open3.stub(:popen3).and_yield(nil, StringIO.new("0.0.1\n0.0.2"), nil)
        ShellUtils.stub(:sh).and_return(<<OUT)
* constrain_bump_to_branch
  master
OUT
        GitVersion.stub(:contained_in_current_branch?).and_return(true)

        expect(GitVersion.latest_from_path('.').to_s).to eq('0.0.2')
      end

      it 'only shells out once if multiple tags are included in the branch' do
        Open3.stub(:popen3).and_yield(nil, StringIO.new("0.0.1\n0.0.2"), nil)
        expect(ShellUtils).to receive(:sh).once.and_return('*')
        GitVersion.latest_from_path('.')
      end
    end
  end
end
