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
        current_version.write_version
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

  end
end
