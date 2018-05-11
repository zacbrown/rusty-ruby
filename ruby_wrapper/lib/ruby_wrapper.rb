require "ruby_wrapper/version"
require 'ffi'

module OS
  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end

  def OS.library_name_by_platform
    return 'ffi/librusty.dylib' if OS.mac?
    return 'ffi/librusty.dll' if OS.windows?
    return 'ffi/librusty.so' if OS.linux?
  end
end

module RubyWrapper
  extend FFI::Library
  ffi_lib OS.library_name_by_platform
  attach_function :process, [], :uint64
end

puts "done 0x" + RubyWrapper.process.to_s(16)