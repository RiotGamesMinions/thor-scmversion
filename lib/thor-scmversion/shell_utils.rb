require 'mixlib/shellout'

module ThorSCMVersion
  class ShellUtils
    class << self
      def secure_password
        password = String.new

        while password.length < 20
          password << ::OpenSSL::Random.random_bytes(1).gsub(/\W/, '')
        end
        password
      end

      def sh(cmd, dir = '.', &block)
        out, code = sh_with_excode(cmd, dir, &block)
        code == 0 ? out : raise(out.empty? ? "Running `#{cmd}` failed. Run this command directly for more detailed output." : out)
      end

      def sh_with_excode(cmd, dir = '.', &block)
        command = Mixlib::ShellOut.new(cmd << " 2>&1", :cwd => dir)
        command.run_command
        [command.stdout, command.exitstatus]
      end
    end
  end
end
