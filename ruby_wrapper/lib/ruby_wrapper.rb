require "ruby_wrapper/version"
require 'ffi'

module RubyWrapper
  extend FFI::Library
  ffi_lib 'ffi/librusty.lib'
  attach_function :process, [], :uint64
end

puts "done 0x" + RubyWrapper.process.to_s(16)