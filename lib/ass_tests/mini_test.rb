module AssTests
  require 'ass_tests/info_bases'
  module MiniTest
    class Test < Minitest::Test
      class ConfigureError < StandardError; end
      def self.use(infobase_name)
        @infobase = AssTests::InfoBases[infobase_name]
      end

      def infobase
        fail ConfigureError if self.class.infobase.nil?
        self.class.infobase
      end
      alias_method :ib, :infobase

      def self.infobase
        @infobase
      end

      def connection_string
        infobase.connection_string
      end
      alias_method :cs, :connection_string

      def platform_require
        infobase.platform_require
      end
      alias_method :pr, :platform_require
    end
  end

end

