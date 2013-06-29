module ThorSCMVersion
  # @author Josiah Kiehl <josiah@skirmisher.net>
  # adapted from code written by Jamie Winsor <jamie@vialstudios.com>
  class SCMVersionError < StandardError
    class << self
      # @param [Integer] code
      def status_code(code)
        define_method(:status_code) { code }
        define_singleton_method(:status_code) { code }
      end
    end

    alias_method :message, :to_s
  end

  class InternalError < SCMVersionError; status_code(99); end

  class TagFormatError < SCMVersionError
    status_code(100)
    def initialize(tag); @tag = tag; end
    def to_s; "#{@tag.inspect} is formatted incorrectly."; end
  end
  class InvalidPrereleaseFormatError < TagFormatError
    def to_s; super + " Format must be: #{Prerelease::FORMAT.inspect}."; end
  end

  class GitError < SCMVersionError; end
  class GitTagError < GitError
    status_code(100)
    def initialize(tag)
      @tag = tag
    end

    def to_s
      msg = "Tried to tag #{@tag}, but it already exists! Either build from the latest tag at this bump level or choose a lower order bump level."
    end
  end
end
