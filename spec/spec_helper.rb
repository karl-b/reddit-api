$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'reddit/api'
Reddit::Internal::Logger.log.level = Log4r::DEBUG
