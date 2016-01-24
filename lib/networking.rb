require 'English'
require 'fiber'
require 'socket'
require 'stringio'

require 'telemetry/logger'

require 'networking/fileno'
require 'networking/scheduler'
require 'networking/scheduler/blocking'
require 'networking/scheduler/cooperative'
require 'networking/scheduler/immediate'
require 'networking/scheduler/substitute'
require 'networking/socket_proxy'
