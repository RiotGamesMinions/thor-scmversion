require 'spec_helper'

module ThorSCMVersion
  shared_examples 'scmversion' do
    it 'should take major minor and patch segments on initialization' do
      described_class.new('1', '2', '3').to_s.should == '1.2.3'
    end
    it 'should optionally take a prerelease' do
      described_class.new('1', '2', '3', Prerelease.new('alpha', 1)).to_s.should == '1.2.3-alpha.1'
    end
    describe 'should take a build number' do
      it do
        described_class.new('1', '2', '3', nil, '2').to_s.should == '1.2.3+build.2'
      end
      it 'and a prerelease' do
        described_class.new('1', '2', '3', Prerelease.new('beta', 3), '2').to_s.should == '1.2.3-beta.3+build.2'
      end
    end
    describe '#bump!' do
      subject { described_class.new('1', '2', '3', Prerelease.new('beta', 3), '2') }
      describe 'should bump' do
        it 'major' do
          subject.bump!(:major).to_s.should == '2.0.0'
        end
        it 'minor' do
          subject.bump!(:minor).to_s.should == '1.3.0'
        end
        it 'patch' do
          subject.bump!(:patch).to_s.should == '1.2.4'
        end
        describe 'auto' do
          it "should respect a default level of bump" do
            subject.bump!(:auto, default: :patch).to_s.should == '1.2.4'
          end
        end
        describe 'prerelease' do
          describe 'with explicit type' do
            it do
              subject.bump!(:prerelease, prerelease_type: 'someth').to_s.should == '1.2.3-someth.1'
            end
            it 'with no prerelease on previous version' do
              subject.prerelease = nil
              subject.bump!(:prerelease, prerelease_type: 'someth').to_s.should == '1.2.4-someth.1'
            end
          end
          describe 'with default type' do
            it do
              subject.bump!(:prerelease).to_s.should == '1.2.3-beta.4'
            end
            it 'with no prerelease on previous version' do
              subject.prerelease = nil
              subject.bump!(:prerelease).to_s.should == '1.2.4-alpha.1'
            end
          end
        end
        it 'build' do
          subject.bump!(:build).to_s.should == '1.2.3-beta.3+build.3'
        end
      end
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
    describe "#reset_for" do
      subject { described_class.new('1', '2', '3', Prerelease.new, '4') }
      [[:major, '1.0.0'],
       [:minor, '1.2.0'],
       [:patch, '1.2.3'],
       [:prerelease, '1.2.3-alpha.1'],
       [:build, '1.2.3-alpha.1+build.4']].each do |type, result|
        it "should reset for #{type}" do
          subject.reset_for(type).to_s.should == result
        end
      end
    end
  end
  describe ScmVersion do
    describe "::VERSION_FORMAT should " do
      %w[1.2.3 1.2.3-alpha.1 1.2.3+build.2 1.2.45-alpha.3+build.52 1.0.0-alpha.3+build.2].each do |example|
        it "match #{example}" do
          example.match(described_class::VERSION_FORMAT).should_not be_nil
        end
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
