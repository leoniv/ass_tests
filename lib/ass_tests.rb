module AssTests
  class ConfigureError < StandardError; end
  require 'ass_ole'
  require 'ass_tests/version'
  require 'ass_tests/config'
  require 'ass_tests/fixt'
  require 'ass_tests/externals'
  require 'ass_tests/info_bases'
  require 'ass_tests/core_patch/win32ole_runtime_error'
  require 'ass_tests/core_patch/no_method_error'
end

