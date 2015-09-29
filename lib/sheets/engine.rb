module Sheets
  class Engine < ::Rails::Engine
    require 'pusher'
    require 'RubyXL'
    config.autoload_paths << File.expand_path("../lib/some/path", __FILE__)
  end
end
