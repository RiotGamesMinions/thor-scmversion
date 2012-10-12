module ThorSCMVersion
  class Prerelease
    TYPE_FORMAT = /[A-Za-z0-9]+/
    FORMAT = /(#{TYPE_FORMAT})\.(\d+)/.freeze
    DEFAULT_TYPE = 'alpha'

    class << self
      # Reads the prerelease segment of the version. While semver
      # provides a more general format, the format with
      # thor-scmversion is more strictly defined:
      # 
      # Examples:
      #   str = 'alpha.1'
      #   str = 'beta.10'
      #   str = 'rc.2'
      #
      # @param [String] str String in the format /[A-Za-z]+\.\d+/
      # @return [Prerelease]
      def from_string(str)
        return nil if str.nil?
        matchdata = str.match(FORMAT)
        type, version = matchdata.captures unless matchdata.nil?
        raise InvalidPrereleaseFormatError.new(str) if (matchdata.nil? ||
                                                        matchdata.captures.size != 2)
        new(type, version)
      end
    end

    attr_reader :version
    attr_reader :type

    # initialize
    #
    # @param [String] type Type of prerelease
    # @param [responds_to? :to_i] version Version of the given type of prerelease
    #
    # Examples:
    #   'beta', 1 #=> x.x.x-beta.1
    def initialize(type = DEFAULT_TYPE, version = 1)
      @version = version.to_i
      @type = type.nil? || type.empty? ? DEFAULT_TYPE : type
    end

    def to_s
      "#{@type}.#{@version}"
    end

    def <=>(other)
      raise ArgumentError unless kind_of? other.class
      if self.type == other.type
        self.version <=> other.version
      else
        self.type <=> other.type
      end
    end

    def >(other)
      raise ArgumentError unless kind_of? other.class
      return (self <=> other) == 1
    end

    def <(other)
      raise ArgumentError unless kind_of? other.class
      return (self <=> other) == -1
    end

    def ==(other)
      other &&
        kind_of?(other.class) &&
        self.version == other.version &&
        self.type == other.type
    end

    # Delegate methods to @version so this object acts like an Integer
    def method_missing(method, *args, &blk)
      @version = self.version.send(method, *args, &blk)
      self
    end
  end
end
