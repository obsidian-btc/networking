require 'English'
require 'fiber'
require 'openssl'
require 'socket'
require 'stringio'

require 'telemetry/logger'

require 'connection/fileno'

require 'connection/scheduler'
require 'connection/scheduler/blocking'
require 'connection/scheduler/immediate'
require 'connection/scheduler/substitute'

require 'connection/connection'
require 'connection/substitute'
require 'connection/substitute/assertions'
require 'connection/substitute/expectation'

require 'connection/client'
require 'connection/client/non_ssl'
require 'connection/client/reconnect_policy'
require 'connection/client/ssl'
require 'connection/client/substitute'

require 'connection/server'
require 'connection/server/ssl'
