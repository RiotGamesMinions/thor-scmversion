require 'spec_helper'

module ThorSCMVersion
  shared_examples 'scmversion' do
    it 'should take major minor and patch segments on initialization' do
      described_class.new('1', '2', '3').to_s.should == '1.2.3'
    end
    it 'should optionally take a prerelease' do
      described_class.new('1', '2', '3', Prerelease.new('alpha', 1)).to_s.should == '1.2.3-alpha.1'
    end
    describe '#from_tag should create a version object from a tag' do
      it do
        v = described_class.from_tag('1.2.3')
        v.major.should == 1
        v.minor.should == 2
        v.patch.should == 3
        v.prerelease.should == nil
      end
      it 'with a prerelease' do
        v = described_class.from_tag('1.2.3-alpha.1')
        v.major.should == 1
        v.minor.should == 2
        v.patch.should == 3
        v.prerelease.should == Prerelease.new('alpha', 1)
      end
    end
  end
  describe ScmVersion do
    %w[1.2.3 1.2.3-alpha.1].each do |example|
      it "::VERSION_FORMAT should match #{example}" do
        example.match(ScmVersion::VERSION_FORMAT).should_not be_nil
      end
    end
  end

  describe GitVersion do
    it_behaves_like 'scmversion'
  end
    
  describe Perforce do
    it 'should set environment variables' do
      described_class.stub(:set) { <<-here }
P4CHARSET=utf8\nP4CLIENT=kallan_mac (config)
P4CONFIG=p4config (config '/Users/kallan/src/kallan_mac/p4config')
P4PORT=perflax01:1666 (config)
P4USER=kallan
here

      described_class.parse_and_set_p4_set
      
      ENV["P4CHARSET"].should == "utf8"
      ENV["P4CONFIG"].should == "p4config"
      ENV["P4PORT"].should == "perflax01:1666"
      ENV["P4USER"].should == "kallan"
    end
  end

  describe P4Version do
    it_behaves_like 'scmversion'

    it 'should parse labels correctly' do
      described_class.parse_label("Label testing-1.0.0 2012/10/01 'Created by kallan. '", "testing").should eq(["1","0","0"])
      described_class.parse_label("Label testing-1.0.1 2012/10/01 'Created by kallan. '", "testing").should eq(["1","0","1"])
      described_class.parse_label("Label testing-2.0.5 2012/10/01 'Created by kallan. '", "testing").should eq(["2","0","5"])
      described_class.parse_label("Label testing-4.2.2 2012/10/01 'Created by kallan. '", "testing").should eq(["4","2","2"])
    end
  end
end
