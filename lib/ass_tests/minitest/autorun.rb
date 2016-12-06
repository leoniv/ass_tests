module AssTests
  require 'ass_tests/minitest'
  module Minitests
    module Autorun
      at_exit do
        Autorun.do_at_exit
      end
      require 'minitest/autorun'

      def self.do_at_exit
        # TODO
      end
    end
  end
end
