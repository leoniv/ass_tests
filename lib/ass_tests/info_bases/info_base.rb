module AssTests
  module InfoBases
    require 'ass_maintainer/info_base'
    class InfoBase < AssMaintainer::InfoBase
      OPTIONS = {
        template: nil,
        fixtures: nil,
      }

      OPTIONS.each_key do |key|
        define_method key do
          options[key]
        end
      end

      def self.ALL_OPTIONS()
        AssMaintainer::InfoBase::OPTIONS.merge OPTIONS
      end

      def initialize(name, connection_string, read_only = true, **options)
        super name, connection_string, read_only, **OPTIONS.merge(options)
      end

      def make_infobase!
        super
        load_template
        fixtures.execute(self) if fixtures
        self
      end
      private :make_infobase!

      def load_template
        return unless template
        fail 'FIXME'
      end
    end
  end
end
