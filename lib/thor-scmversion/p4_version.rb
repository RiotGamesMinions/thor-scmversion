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
        ShellUtils.sh "echo #{ENV["P4PASSWD"]} | p4 login"
        yield
      ensure
        ShellUtils.sh "p4 logout"
      end
    end
  end

  class P4Version < ScmVersion
    class << self
      def all_from_path(path)
        Dir.chdir(path) do
          p4_depot_path = ShellUtils.sh("p4 dirs #{File.expand_path(path)}").chomp
          p4_module_name = File.expand_path(path).split("/").last

          all_labels_array = ShellUtils.sh("p4 labels -e \"#{p4_module_name}*\" #{p4_depot_path}/...").split("\n")
          thor_scmversion_labels = all_labels_array.select{|label| label.split(" ")[1].gsub("#{p4_module_name}-", "").match(ScmVersion::VERSION_FORMAT)}

          current_versions = thor_scmversion_labels.collect do |label|
            new_instance = new(*parse_label(label, p4_module_name), p4_module_name, path)
            new_instance
          end.sort.reverse

          current_versions << new(0, 0, 0, p4_module_name, path) if current_versions.empty?
          current_versions
        end
      end

      def parse_label(label, p4_module_name)
        label.split(" ")[1].gsub("#{p4_module_name}-", "").split('.')
      end
    end
    
    attr_accessor :version_file_path
    attr_accessor :p4_module_name
    attr_accessor :path

    def initialize(major, minor, patch, p4_module_name, path)
      @major = major.to_i
      @minor = minor.to_i
      @patch = patch.to_i
      @p4_module_name = p4_module_name
      @path = path
    end

    def retrieve_tags
      # noop
      # p4 always has labels available, you just have to ask the server for them.
    end
    
    def tag
      `p4 label -o #{get_label_name}`
      `p4 tag -l #{get_label_name} #{File.join(File.expand_path(path), "")}...#head`
    end

    def auto_bump
      # TODO: actually implement this
      bump!(:patch)
    end

    private

      def get_label_name
        "#{p4_module_name}-#{self}"  
      end
  end
end
