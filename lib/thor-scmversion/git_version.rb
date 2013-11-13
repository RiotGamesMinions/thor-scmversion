require 'open3'

module ThorSCMVersion
  class GitVersion < ScmVersion
    class << self
      def all_from_path(path)
        Dir.chdir(path) do
          tags = Open3.popen3("git tag") { |stdin, stdout, stderr| stdout.read }.split(/\n/)
          tags.select { |tag| tag.match(ScmVersion::VERSION_FORMAT) }
            .collect { |tag| from_tag(tag) }
            .select { |tag| contained_in_current_branch?(tag) }.sort.reverse
        end
      end

      def contained_in_current_branch?(tag)
        ShellUtils.sh("git branch --contains #{tag}") =~ /\*/
      end

      def retrieve_tags
        ShellUtils.sh("git fetch --all")
      end
    end

    def tag
      begin
        ShellUtils.sh "git tag -a -m \"Version #{self}\" #{self}"
      rescue => e
        raise GitTagDuplicateError.new(self.to_s)
      end
      remote = ShellUtils.sh("git config branch.`git name-rev --name-only HEAD`.remote").chomp
      ShellUtils.sh "git push  #{remote} refs/tags/#{self} || true"
    end

    # Check the commit messages to see what type of bump is required
    def auto_bump(options)
      last_tag = self.class.from_path.to_s
      logs = ShellUtils.sh "git log --abbrev-commit --format=oneline #{last_tag}.."
      guess = if logs =~ /\[major\]|\#major/i
                :major
              elsif logs =~ /\[minor\]|\#minor/i
                :minor
              elsif logs =~ /\[prerelease\s?(#{Prerelease::TYPE_FORMAT})?\]|\#prerelease\-?(#{Prerelease::TYPE_FORMAT})?/
                prerelease_type = $1 || $2
                :prerelease
              elsif logs =~ /\[patch\]|\#patch/i
                :patch
              else
                options[:default] or :build
              end
      bump!(guess, prerelease_type: prerelease_type)
    end
  end
end
