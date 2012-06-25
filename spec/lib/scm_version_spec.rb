require 'spec_helper'

module ThorSCMVersion
  describe GitVersion do
    it 'should take major minor and patch segments on initialization' do
      -> { described_class.new('1', '2', '3') }.should_not raise_error
    end
  end
    
  describe Perforce do
    it 'should set good' do
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
end
