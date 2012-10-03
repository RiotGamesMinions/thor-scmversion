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

          all_labels_array = ShellUtils.sh("p4 labels -e \"#{p4_module_name}*\"").split("\n")
          thor_scmversion_labels = get_thor_scmversion_labels(all_labels_array, p4_module_name)

          current_versions = thor_scmversion_labels.collect do |label|
            new_instance = new(*parse_label(label, p4_module_name))
            new_instance.p4_depot_path = p4_depot_path
            new_instance.p4_module_name = p4_module_name
            new_instance.path = path
            new_instance
          end.sort.reverse

          if current_versions.empty?
            first_instance = new(0, 0, 0)
            first_instance.p4_depot_path = p4_depot_path
            first_instance.p4_module_name = p4_module_name
            first_instance.path = path
          end 

          current_versions << first_instance if current_versions.empty?
          current_versions
        end
      end

      def parse_label(label, p4_module_name)
        label.split(" ")[1].gsub("#{p4_module_name}-", "").split('.')
      end

      def get_thor_scmversion_labels(labels, p4_module_name)
        labels.select{|label| label.split(" ")[1].gsub("#{p4_module_name}-", "").match(ScmVersion::VERSION_FORMAT)}        
      end
    end
    
    attr_accessor :version_file_path
    attr_accessor :p4_depot_path
    attr_accessor :p4_module_name
    attr_accessor :path

    def retrieve_tags
      # noop
      # p4 always has labels available, you just have to ask the server for them.
    end
    
    def tag
      #`p4 label -o #{get_label_name}`
      #`p4 tag -l #{get_label_name} #{File.join(File.expand_path(path), "")}...#head`
      `#{cat_or_type} #{File.expand_path(get_p4_label_file)} | p4 label -i`
    end

    def auto_bump
      # TODO: actually implement this
      bump!(:patch)
    end

    private

      def get_label_name
        "#{p4_module_name}-#{self}"  
      end

      def get_p4_label_template
        %{
Label:  #{get_label_name}

Description:
  Created by thor-scmversion.

Owner: #{ENV["P4USER"]}

Options:  unlocked

Revision: @#{get_last_submitted_p4_changelist}

View:
  #{p4_depot_path}/...}
      end

      def get_last_submitted_p4_changelist
        `p4 changes -s submitted -m 1 #{p4_depot_path}/...`.split(' ')[1]
      end

      def get_p4_label_file
        tmp_dir = Dir.mktmpdir
        File.open(File.join(tmp_dir, "p4_label.tmp"), "w") do |file|
          file.write(get_p4_label_template)
          file
        end
      end

      def cat_or_type
        case RbConfig::CONFIG["arch"]
        when /darwin/
          "cat"
        when /cygwin|mswin|mingw|bccwin|wince|emx/
          "type"
        end
      end
  end
end
