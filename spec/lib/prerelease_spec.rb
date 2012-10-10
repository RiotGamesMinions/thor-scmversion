require 'spec_helper'

module ThorSCMVersion
  describe Prerelease do
    subject { Prerelease.new }
    describe "#to_s" do
      it { subject.to_s.should == "alpha.1" }
    end
    describe "#method_missing" do
      it { (subject + 1).class.should == Prerelease }
      it { (subject + 1).version.should == 2 }
      it { pending; (subject += 1).version.should == 2 } #TODO jk figure out why this doesn't work. Works in irb.
    end
  end
end
