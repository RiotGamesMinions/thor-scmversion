module ThorSCMVersion
  VERSION = IO.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION')) rescue "0.0.1"
end
