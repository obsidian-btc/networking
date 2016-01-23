require 'fiber'
require 'socket'

require 'telemetry/logger'

require 'networking/fileno'

require 'networking/scheduler/blocking'
require 'networking/scheduler/cooperative'
require 'networking/scheduler/immediate'
