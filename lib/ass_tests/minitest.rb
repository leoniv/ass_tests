require 'ass_tests'
module AssTests
  module Minitests
    require 'minitest'
    require 'minitest/spec'
    require 'ass_tests/minitest/assertions'
    require 'ass_tests/core_patch/win32ole_runtime_error'
    require 'ass_tests/core_patch/no_method_error'
  end
end
