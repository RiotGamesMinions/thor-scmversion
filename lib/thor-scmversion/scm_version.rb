module ThorSCMVersion

  class << self
    def versioner
      if(File.directory?(".git"))
        return GitVersion
      else
        return P4Version
      end
    end
  end

  class ScmVersion
    include Comparable
    
    VERSION_FORMAT = /^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)$/
    class << self
      def from_path(path = '.')
        all_from_path(path).first || new(0,0,1)
      end
    end
    attr_accessor :major
    attr_accessor :minor
    attr_accessor :patch
    
    def initialize(major=0, minor=0, patch=0)
      @major = major.to_i
      @minor = minor.to_i
      @patch = patch.to_i
    end
    
    def bump!(type)
      case type.to_sym
      when :major
        self.major += 1
        self.minor = 0
        self.patch = 0
      when :minor
        self.minor += 1
        self.patch = 0
      when :patch
        self.patch += 1
      else
        raise "Invalid release type: #{type}. Valid types are: major, minor, or patch"
      end
      raise "Version: #{self.to_s} is less than or equal to the existing version." if self <= self.class.from_path
      self
    end
    
    def tag
      raise NotImplementedError
    end
    
    def to_s
      "#{major}.#{minor}.#{patch}"
    end
    alias_method :version, :to_s
    
    def <=>(other)
      return unless other.is_a?(self.class)
      return 0 if self.version == other.version
      
      [:major, :minor, :patch].each do |segment|
        next      if self.send(segment) == other.send(segment)
        return  1 if self.send(segment) > other.send(segment)
        return -1 if self.send(segment) < other.send(segment)
      end
      return 0
    end
  end
end
