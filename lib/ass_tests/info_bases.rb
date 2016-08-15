module AssTests
  module InfoBases
    require 'ass_tests'
    require 'ass_tests/info_base'

    module DescribeDSL

      class AbstractDescriber
        def ib(&block)
          instance_eval(&block) if block_given?
          InfoBase.new(ib_name, connection_string, external?, options)
        end

        def external?
          instance_of? ExternalIb
        end
      end

      module DescribeOptions
        def options
          @options ||= InfoBase::OPTIONS.clone
        end

        def method_missing(method, *args)
          if options.key? method
            options[method] = args[0]
          else
            fail NoMethodError, method.to_s
          end
        end
      end

      class ExternalIb < AbstractDescriber
        include DescribeOptions

        attr_reader :ib_name, :connection_string

        def initialize(ib_name, connection_string)
          @ib_name = ib_name
          @connection_string = AssLauncher::Support::ConnectionString\
            .new(connection_string)
        end
      end

      module CommonDescriber
        attr_reader :ib_name, :connection_string
        alias_method :cs, :connection_string

        private :connection_string, :cs
        def initialize(ib_name)
          @ib_name = ib_name
          @connection_string = init_connection_string
        end

        def user(value)
          cs.usr = value
        end

        def password(value)
          cs.pwd = value
        end

        def locale(value)
          cs.locale = value
        end
      end

      class FileIb < AbstractDescriber
        include CommonDescriber
        include DescribeOptions

        def directory(d)
          cs.file = File.join(d, ib_name.to_s)
        end

        def init_connection_string
          AssLauncher::Support::ConnectionString::File\
            .new({file: default_path})
        end
        private :init_connection_string

        def default_path
          File.join(AssTests.config.test_infobase_directory, ib_name.to_s)
        end
        private :default_path
      end

      class ServerIb < AbstractDescriber
        include CommonDescriber
        include DescribeOptions

        def agent(str)
          @agent = InfoBase::ServerIb::AgentConnection.parse_str(str)
          @agent
        end

        def claster(str)
          @claster = InfoBase::ServerIb::ClasterConnection.parse_str(str)
          @claster.fill_cs(cs)
          @claster
        end

        def db(str)
          @db = InfoBase::ServerIb::Db.parse_str(str)
          @db.fill_cs(cs)
          @db
        end

        def schjobdn
          cs.schjobdn = 'Y'
        end

        def ib(&block)
          ib = super
          ib.db = _db
          ib.agent = _agent
          ib.claster = _claster
          ib
        end

        def init_connection_string
          @connection_string = AssLauncher::Support::ConnectionString::Server\
            .new({srvr: 'localhost:1540', ref: ib_name.to_s})
          init_connections
          @connection_string
        end
        private :init_connection_string

        def _db
          @db ||= InfoBase::ServerIb::Db\
            .parse_str(AssTests.config.test_infobase_db\
                       + " --db-name #{ib_name}")
        end
        private :_db

        def _agent
          @agent ||= InfoBase::ServerIb::AgentConnection\
            .parse_str(AssTests.config.test_infobase_server_agent)
        end
        private :_agent

        def _claster
          @claster ||= InfoBase::ServerIb::ClasterConnection\
            .parse_str(AssTests.config.test_infobase_claster)
        end
        private :_claster

        def init_connections
          _db.fill_cs(cs)
          _claster.fill_cs(cs)
        end
        private :init_connections
      end
    end

    def self.pull
      @pull ||= {}
    end
    private_class_method :pull

    def self.[](name)
      fail ArgumentError, "InfoBase `#{name}' not discribed" unless\
        pull.key? name
      ib = pull[name]
      ib.make
      ib
    end

    def self.describe(&block)
      fail ArgumentError, 'Require block' unless block_given?
      instance_eval(&block)
    end

    def self.file(ib_name, &block)
      desc = DescribeDSL::FileIb.new(ib_name)
      add(desc.ib(&block))
    end

    def self.server(ib_name, &block)
      desc = DescribeDSL::ServerIb.new(ib_name)
      add(desc.ib(&block))
    end

    def self.external(ib_name, connection_string, &block)
      desc = DescribeDSL::ExternalIb.new(ib_name, connection_string)
      add(desc.ib(&block))
    end

    def self.add(ib)
      fail ArgumentError, "Ib #{ib.name} already described" if pull.key? ib.name
      pull[ib.name] = ib
    end
  end
end
