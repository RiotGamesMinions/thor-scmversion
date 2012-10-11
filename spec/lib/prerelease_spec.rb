require 'spec_helper'

module ThorSCMVersion
  describe Prerelease do
    subject { Prerelease.new }
    describe "::new" do
      it { subject.to_s.should == 'alpha.1' }
      it "should default to alpha if provided a nil or empty type" do
        described_class.new('').type.should == 'alpha'
      end
    end
    describe "::FORMAT" do
      %w[alpha.1 beta.124].each do |example|
        it "should match #{example}" do
          example.match(described_class::FORMAT).should_not be_nil
        end
      end
    end
    describe "#to_s" do
      it { subject.to_s.should == "alpha.1" }
    end
    describe "#method_missing" do
      it { (subject + 1).class.should == Prerelease }
      it { (subject + 1).version.should == 2 }
      it { pending("Figure out why this doesn't work. Works in irb."); (subject += 1).version.should == 2 } #TODO jk 
    end
    describe "#<=>" do
      [[['alpha', 5], ['beta', 1], false],
       [['alpha', 5], ['alpha', 2], true],
       [['alpha', 5], ['zzz', 1], false]].each do |params|
        it "#{params[0].inspect} should #{params[2] ? '' : 'not'} be greater than #{params[1].inspect}" do
          (described_class.new(*params[0]) > described_class.new(*params[1])).should == params[2]
        end
        it "#{params[0].inspect} should #{params[2] ? '' : 'not'} be less than #{params[1].inspect}" do
          
          (described_class.new(*params[0]) < described_class.new(*params[1])).should == !params[2]
        end
      end
    end
    describe "::from_string" do
      it 'should parse the segment of the semver containing the prerelease information' do
        p = described_class.from_string('alpha.1')
        p.type.should == 'alpha'
        p.version.should == 1
      end
      it 'should return nil if the str passed in is nil' do
        described_class.from_string(nil).should be_nil
      end
      %w[1 1.1 1.alpha alpha alpha.alpha .1].each do |str|
        it "with the captures #{str} should raise an error if an invalid format is provided" do
          -> { Prerelease.from_string(str) }.should raise_error(InvalidPrereleaseFormatError)
        end
      end
    end
  end
end
