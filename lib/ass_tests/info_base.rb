module AssTests
  class InfoBase
    module FixturesInterface
      attr_reader :infobase
      def execute(infobase)
        @infobase = infobase
        entry_point
      end
    end

    module IbMakerInterface
      attr_reader :infobase
      def execute(infobase)
        @infobase = infobase
        entry_point
      end
    end

    module IbDestroyerInterface
      attr_reader :infobase
      def execute(infobase)
        @infobase = infobase
        entry_point
      end
    end

    class DefaultMaker
      include IbMakerInterface
      def entry_point
        thick = infobase.ass_client
        cmd = thick.command(:createinfobase, create_args)
        cmd.run.wait.result.verify!
      end

      def template_path
        r = AssLauncher::Support::Platforms.path(infobase.template)
        fail "Template path #{r} not exists" unless r.file?
        r
      end
      private :template_path

      def create_args
        r = infobase.connection_string.createinfobase_args
        r += ['/UseTemplate', template_path.to_s] if\
          infobase.template
        r
      end
      private :create_args
    end

    OPTIONS = {
      template: nil,
      fixtures: nil,
      maker: nil,
      destroyer: nil,
      platform_require: AssTests.config.platform_require,
      before_make: ->(ib){},
      after_make: ->(ib){},
      before_rm: ->(ib){},
      after_rm: ->(ib){}
    }

    OPTIONS.each_key do |key|
      next if key == :maker || key == :destroyer
      define_method key do
        options[key]
      end
    end
    require 'ass_tests/info_base/file_ib'
    require 'ass_tests/info_base/server_ib'

    attr_reader :name, :connection_string, :options
    def initialize(name, connection_string, external = true, **options)
      @name = name
      @connection_string =
        AssLauncher::Support::ConnectionString.new(connection_string.to_s)
      @external = external
      @options = OPTIONS.merge(options)
      if connection_string.is? :file
        extend FileIb
      elsif connection_string.is? :server
        extend ServerIb
      else
        fail ArgumentError
      end
    end

    def is
      connection_string.is
    end

    def is?(type)
      connection_string.is?(type)
    end

    def usr=(user_name)
      connection_string.usr = user_name
    end

    def usr
      connection_string.usr
    end

    def pwd=(password)
      connection_string.pwd = password
    end

    def pwd
      connection_string.pwd
    end

    def ass_client
      AssLauncher::Enterprise.thick_clients(platform_require).sort.last ||\
        fail("Platform 1C #{platform_require} not found")
    end

    def make
      return self if external?
      make_infobase unless exists?
      self
    end

    def make_infobase
      before_make.call(self)
      maker.execute(self)
      after_make.call(self)
      fixtures.execute(self) if fixtures
      self
    end
    private :make_infobase

    def external?
      @external
    end

    def rm!(sure = :no)
      fail "Infobase #{name} is external. Remove denied!" if external?
      fail 'If you are sure pass :yes value' unless sure == :yes
      return unless exists?
      rm_infobase!
      nil
    end

    def rm_infobase!
      befor_rm.call(self)
      destroyer.execute(self)
      after_rm.call(self)
    end
    private :rm_infobase!

    def rebuild
      rm! :yes
      make
    end
  end
end
