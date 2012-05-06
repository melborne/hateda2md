#!/usr/bin/env ruby
# encoding: UTF-8
module HateDa
  require_relative 'hateda2md/entry'
  require_relative 'hateda2md/mdbuilder'
  require_relative 'hateda2md/converter'
  require_relative 'hateda2md/system_extension'

  Entry.send(:include, Converter)
end

