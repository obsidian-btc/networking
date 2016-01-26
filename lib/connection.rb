require 'English'
require 'fiber'
require 'openssl'
require 'socket'
require 'stringio'

require 'telemetry/logger'

require 'connection/connection'
require 'connection/fileno'

require 'connection/scheduler'
require 'connection/scheduler/blocking'
require 'connection/scheduler/cooperative'
require 'connection/scheduler/immediate'
require 'connection/scheduler/substitute'

require 'connection/client'
require 'connection/client/non_ssl'
require 'connection/client/reconnect_policy'
require 'connection/client/ssl'
require 'connection/client/substitute'

require 'connection/server'
require 'connection/server/ssl'
require 'connection/socket_proxy'
require 'connection/socket_proxy/substitute'
require 'connection/socket_proxy/substitute/assertions'
require 'connection/socket_proxy/substitute/expectation'
