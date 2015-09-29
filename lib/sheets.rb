module Sheets
  
  if defined?(Rails)
    require 'pusher'
    require 'RubyXL'
    require "sheets/engine"
    require "sheets/content_type_validator"
  end
end
