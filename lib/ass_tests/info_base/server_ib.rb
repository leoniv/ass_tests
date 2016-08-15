module AssTests
  class InfoBase
    module ServerIb
      require 'ass_tests/info_base/server_ib/helpers'
      class ServerBaseDestroyer
        include IbDestroyerInterface
        def entry_point
          fail NotImplementsError
        end
      end

      attr_accessor :agent, :claster, :db

      def maker
        options[:maker] || DefaultMaker.new
      end
      private :maker

      def exists?
        fail NotImplementsError
      end

      def distroer
        options[:distroer] || ServerBaseDestroyer.new
      end
      private :distroer
    end
  end
end
