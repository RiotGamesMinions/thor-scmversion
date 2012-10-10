module ThorSCMVersion
  class Prerelease
    attr_reader :version
    attr_reader :type

    def initialize(version = 1, type = "alpha")
      @version = version
      @type = type
    end

    def to_s
      "#{@type}.#{@version}"
    end

    def method_missing(method, *args, &blk)
      ret = @version.send(method, *args, &blk)
      ret.is_a?(Numeric) ? Prerelease.new(ret) : ret
    end
  end
end
