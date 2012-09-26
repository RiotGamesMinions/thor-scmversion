require 'thor'
require 'thor-scmversion/scm_version'
require 'thor-scmversion/git_version'
require 'thor-scmversion/p4_version'
require 'thor-scmversion/shell_utils'

module ThorSCMVersion
  class Tasks < Thor
    namespace "version"

    desc "bump TYPE", "Bump version number (type is major, minor, patch or auto)"
    def bump(type)
      current_version.bump! type
      begin
        say "Creating and pushing tags", :yellow
        current_version.tag
        say "Writing files: #{version_files.join(', ')}", :yellow
        write_version
        say "Tagged: #{current_version}", :green
      rescue => e
        say "Tagging #{current_version} failed due to error", :red
        say e, :red
        exit 1
      end
    end

    desc "current", "Show current SCM tagged version"
    def current
      write_version
      say current_version.to_s
    end

    private
    def current_version
      @current_version ||= ThorSCMVersion.versioner.from_path
    end

    def write_version
      current_version.write_version(version_files)
    end

    eval "def source_root ; Pathname.new File.dirname(__FILE__) ; end"
    def version_files
      [
       source_root.join('VERSION')
      ]
    end
    


  end
end
