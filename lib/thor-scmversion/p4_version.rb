module ThorSCMVersion
  class << self
    def windows?
      RbConfig::CONFIG["arch"] =~ /cygwin|mswin|mingw|bccwin|wince|emx/
    end
  end

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
          all_labels_array = `p4 labels -e \"#{module_name(path)}*\"`.split("\n")
          thor_scmversion_labels = get_thor_scmversion_labels(all_labels_array, module_name(path))

          current_versions = thor_scmversion_labels.collect do |label|
            new_instance = new(*parse_label(label, module_name(path)))
          end.sort.reverse

          if current_versions.empty?
            first_instance = new(0, 0, 0)
          end

          current_versions << first_instance if current_versions.empty?
          current_versions
        end
      end

      def latest_from_path(path)
        all_from_path(path).first
      end

      def depot_path(path)
        path = File.expand_path(path)
        path = path.gsub(File::Separator, File::ALT_SEPARATOR) if ThorSCMVersion.windows?
        `p4 where "#{path}/..."`.split(" ").first.gsub("/...", "")
      end

      def module_name(path)
        depot_path(path).gsub("//", "").gsub("/", "-")
      end

      def parse_label(label, p4_module_name)
        label.split(" ")[1].gsub("#{p4_module_name}-", "").split('.')
      end

      def get_thor_scmversion_labels(labels, p4_module_name)
        labels.select{|label| label.split(" ")[1].gsub("#{p4_module_name}-", "").match(ScmVersion::VERSION_FORMAT)}
      end
    end

    def initialize(major = 0, minor = 0, patch = 0, prerelease = nil, build = 1)
      self.p4_depot_path = self.class.depot_path('.')
      self.p4_module_name = self.class.module_name('.')
      super
    end

    attr_accessor :version_file_path
    attr_accessor :p4_depot_path
    attr_accessor :p4_module_name

    def retrieve_tags
      # noop
      # p4 always has labels available, you just have to ask the server for them.
    end

    def tag
      if ThorSCMVersion.windows?
        `type "#{File.expand_path(get_p4_label_file).gsub(File::Separator, File::ALT_SEPARATOR)}" | p4 label -i`
      else
        `cat "#{File.expand_path(get_p4_label_file)}" | p4 label -i`
      end
    end

    def auto_bump(options)
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
  end
end
