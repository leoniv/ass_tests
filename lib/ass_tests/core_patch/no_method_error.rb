require 'ass_tests/core_patch/standard_error'
# Monkey patch for encoding error message
class NoMethodError
  __patch_message__
end
