module ThorSCMVersion

  class << self
    # Figures out whether the repository is managed by git. If not, use p4.
    #
    # @return [#kind_of? ScmVersion]
    def versioner
      if(File.directory?(".git"))
        return GitVersion
      else
        return P4Version
      end
    end
  end

  # author Josiah Kiehl <josiah@skirmisher.net>
  class ScmVersion
    include Comparable
    
    # Tags not matching this format will not show up in the tags list
    #
    # Examples:
    #   1.2.3 #=> valid
    #   1.2.3.4 #=> invalid
    #   1.2.3-alpha.1 #=> valid
    #   1.2.3-alpha #=> invalid
    VERSION_FORMAT = /^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)-?(?<prerelease>#{Prerelease::FORMAT})?$/

    # Default file to write the current version to
    VERSION_FILENAME = 'VERSION'
    class << self
      # Retrieve all versions from the repository contained at path
      #
      # @param [String] path Path to the repository
      # @return [Array<ScmVersion>]
      def from_path(path = '.')
        retrieve_tags
        all_from_path(path).first || new(0,0,1)
      end

      # Create an ScmVersion object from a tag
      #
      # @param [String] tag
      # @return [ScmVersion]
      def from_tag(tag)
        base_version, prerelease_string = tag.split /-/
        major, minor, patch = base_version.split /\./
        new(major, minor, patch, Prerelease.from_string(prerelease_string))
      end

      # In distributed SCMs, tags must be fetched from the server to
      # ensure that the latest tags are being used to calculate the
      # next version.
      def retrieve_tags
        # noop
      end
    end
    attr_accessor :major
    attr_accessor :minor
    attr_accessor :patch
    attr_accessor :prerelease

    def initialize(major = 0, minor = 0, patch = 0, prerelease = nil)
      @major = major.to_i
      @minor = minor.to_i
      @patch = patch.to_i
      @prerelease = prerelease
    end

    # Bumps the version in place
    # 
    # @param [Symbol] type Type of bump to be performed
    # @param [String] prerelease_type Type of prerelease to bump to when doing a :prerelease bump
    # @return [ScmVersion]
    def bump!(type, prerelease_type = nil)
      case type.to_sym
      when :auto
        self.auto_bump
      when :major
        self.major += 1
        self.minor = 0
        self.patch = 0
      when :minor
        self.minor += 1
        self.patch = 0
      when :patch
        self.patch += 1
      when :prerelease
        if self.prerelease
          if prerelease_type.nil? || prerelease_type == self.prerelease.type
            self.prerelease += 1
          else
            self.prerelease = Prerelease.new(prerelease_type)
          end
        else
          self.patch += 1
          self.prerelease = Prerelease.new(prerelease_type)
        end
      else
        raise "Invalid release type: #{type}. Valid types are: major, minor, patch, or auto"
      end
      raise "Version: #{self.to_s} is less than or equal to the existing version." if self <= self.class.from_path
      self
    end

    # Write the version to the passed in file paths
    #
    # @param [Array<String>] files List of files to write
    def write_version(files = [ScmVersion::VERSION_FILENAME])
      files.each do |ver_file|
        File.open(ver_file, 'w+') do |f| 
          f.write self.to_s
        end
      end
      self
    end

    # Create the tag in the SCM corresponding to the version contained in self. 
    # Abstract method. Must be implemented by subclasses.
    def tag
      raise NotImplementedError
    end

    # Perform a bump by reading recent commit messages in the SCM
    # Abstract method. Must be implemented by subclasses.
    def auto_bump(prerelease_type = nil)
      raise NotImplementedError
    end
    
    def to_s
      s = "#{major}.#{minor}.#{patch}"
      s += "-#{prerelease}" unless prerelease.nil?
      s
    end
    alias_method :version, :to_s
    
    def <=>(other)
      return unless other.is_a?(self.class)
      return 0 if self.version == other.version
      
      [:major, :minor, :patch, :prerelease].each do |segment|
        next      if self.send(segment) == other.send(segment)
        return  1 if self.send(segment) > other.send(segment)
        return -1 if self.send(segment) < other.send(segment)
      end
      return 0
    end
  end
end
