module Sheets
  class Engine < ::Rails::Engine
    require 'pusher'
    require 'RubyXL'
    config.autoload_paths << File.expand_path("../../lib", __FILE__)
  end
end
