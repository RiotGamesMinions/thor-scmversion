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
        cmd << " 2>&1"
        output = ""
        status = nil
        Dir.chdir(dir) {
          stdin, stdout, stderr, wait_thr = Open3::popen3(cmd)
          
          status = wait_thr.value
          output = stdout.readlines.join

          if status.to_i == 0
            block.call(output) if block
          end
        }
        [ output, status ]
      end
    end
  end
end
