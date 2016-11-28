module AssTests
  class ConfigureError < StandardError; end
  require 'ass_tests/version'
  require 'ass_tests/config'
  require 'ass_tests/assertions'
  require 'ass_tests/fixt'
  require 'ass_tests/externals'
end

class WIN32OLERuntimeError
  old_message = instance_method(:message)
  define_method(:message) do
    old_message.bind(self).call.force_encoding('ASCII-8BIT')\
      .split('HRESULT')[0].force_encoding('UTF-8').strip
  end
end
