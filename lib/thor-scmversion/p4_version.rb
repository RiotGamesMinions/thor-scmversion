module ThorSCMVersion
  class MissingP4ConfigException < StandardError
    def initialize(config_option)
      @config_option = config_option
    end
    
    def message
      "#{@config_option} is not set in your environment."
    end
  end
  
  module Perforce
    class << self
      def check_environment
        ["P4PORT","P4USER", "P4PASSWD", "P4CLIENT"].each {|config|
          raise MissingP4ConfigException.new(config) if ENV[config].nil? or ENV[config].empty?
        }
      end
      
      def set
        ShellUtils.sh "p4 set"
      end
      
      def parse_and_set_p4_set
        p4_set = set
        parsed_p4_config = p4_set.split("\n").inject({}) do |p4_config, line|
          key, value = line.split('=')
          value = value.gsub(/\(.*/, '').strip unless value.nil?
          p4_config[key] = value
          p4_config
        end
        
        parsed_p4_config.each {|key,value| ENV[key] = value}
      end
      
      def connection
        parse_and_set_p4_set
        check_environment
        #p4.connect
        #p4.run_login
        ShellUtils.sh "echo #{ENV["P4PASSWD"]} | p4 login"
        yield
      ensure
        #p4.run_logout
        ShellUtils.sh "p4 logout"
        #p4.disconnect
      end
    end
  end

  class P4Version < ScmVersion
    class << self
      def all_from_path(path)
        file_path = File.expand_path(File.join(path, 'VERSION'))
        version = new(*File.read(file_path).strip.split("."))
        version.version_file_path = file_path
        [version]
      end
    end
    
    attr_accessor :version_file_path
    
    def tag
      description = "Bump version to #{to_s}."
      `p4 edit -c default "#{self.version_file_path}"`
      File.open(self.version_file_path, 'w') { |f| f.write to_s }
      `p4 submit -d "#{description}"`
      #Perforce.connection do
      #new_changelist = p4.fetch_change
      #new_changelist._Description = "Bump version to #{to_s}."
      #saved_changelist = p4.save_change(new_changelist)
      #changelist_number = saved_changelist[0].match(/(\d+)/).to_s.strip
      #puts changelist_number
      #p4.run_edit("-c", changelist_number, self.version_file_path)
      #changelist = p4.fetch_change changelist_number
      #p4.run_submit changelist
      #end
    end
  end
end
