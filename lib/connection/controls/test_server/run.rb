require 'pathname'

root = Pathname.new Dir.pwd
current_dir = Pathname.new __dir__

path = root.join('init.rb').relative_path_from(current_dir)

require_relative path
require 'connection/controls'

Networking::Controls::TestServer.()
