$:.push File.expand_path('../lib', __FILE__)
require 'thor'
require 'thor-scmversion'

class ThorSCMVersion < Thor
  namespace 'scmver'

  desc "build", "Build the gem"
  def build
    system("gem build -V 'thor-scmversion.gemspec'")
    FileUtils.mkdir_p(File.join(File.dirname(__FILE__), 'pkg'))
    FileUtils.mv("thor-scmversion-#{current_version}.gem", 'pkg')
  end

  desc "install", "Build and install latest to system gems"
  def install
    invoke "build", []
    system("gem install pkg/thor-scmversion-#{current_version}.gem")
  end

  desc "release TYPE", "Bump version, make a build, and push to Rubygems"
  def release(type)
    @current_version = nil
    invoke "version:bump", [type]
    invoke "build", []
    system("gem push pkg/thor-scmversion-#{current_version}.gem")
  end
    
  private
  def current_version
    @current_version ||= ::ThorSCMVersion.versioner.from_path
  end
end
