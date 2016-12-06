module AssTests
  module InfoBases
    require 'ass_tests/info_bases/info_base'
    module DSL
      module Describer
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
            @options ||= InfoBase.ALL_OPTIONS.clone
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
              .new(connection_string.to_s)
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
          module Helpers
            require 'shellwords'
            require 'optparse'

            module Parser
              def options_help
                options.to_a
              end

              def opts
                @opts ||= OptionParser.new
              end

              def parse_str(str)
                parse Shellwords.shellwords(str.to_s)
              end

              def presult
                @presult ||= {}
              end
              private :presult
            end

            class ServerConnection
              include AssMaintainer::InfoBase::ServerIb::EnterpriseServers::ServerConnection
              extend Parser
              def self.options
                opts.on('-H', '--host HOST:PORT') do |v|
                  presult[:host_port] = v
                end
                opts.on('-U', '--user [USER_NAME]') do |v|
                  presult[:user] = v
                end
                opts.on('-P', '--password [PASSWORD]') do |v|
                  presult[:password] = v
                end
                opts
              end

              def self.parse(argv)
                options.parse! argv
                new presult[:host_port], presult[:user], presult[:password]
              end
            end

            class AgentConnection < ServerConnection
              def self.parse(argv)
                super(argv).to_server_agent
              end

              def to_server_agent
                AssMaintainer::InfoBase::ServerIb::EnterpriseServers::ServerAgent.new(host_port,
                                                                  user,
                                                                  password)
              end
            end

            class ClasterConnection < ServerConnection
              def fill_cs(cs)
                cs.srvr = host_port.to_s
                cs.susr = user
                cs.spwd = password
              end

              def to_connstr
                r = ""
                r << "Srvr=\"#{host_port}\";"
                r << "SUsr=\"#{user}\";" if user
                r << "SPwd=\"#{password}\";" if password
                r
              end
            end

            class DbConnection < ServerConnection
              def fill_cs(cs)
                cs.dbsrvr = host_port.to_s
                cs.dbuid = user
                cs.dbpwd = password
              end

              def to_connstr
                r = ""
                r << "DBSrvr=\"#{host_port}\";"
                r << "DBUID=\"#{user}\";" if user
                r << "DBPwd=\"#{password}\";" if password
                r
              end
            end

            class Db < DbConnection
              extend Parser
              def self.options
                opts = super
                opts.on("-D" ,"--dbms [#{AssLauncher::Support::ConnectionString::\
                        Server::DBMS_VALUES.join(' | ')}]",
                        'Type of DB for connection string') do |v|
                  presult[:dbms] = v
                end
                opts.on('-N','--db-name [DBNAME]','Name of databse') do |v|
                  presult[:name] = v
                end
                opts.on('-C','--create-db [Y|N]',
                        'Crate databse if not exists. Default Y') do |v|
                  presult[:create_db] = v
                end
                opts
              end

              def self.parse(argv)
                options.parse! argv
                srv_conn = DbConnection.new(
                  presult[:host_port], presult[:user], presult[:password])
                new presult[:name], srv_conn, presult[:dbms], presult[:create_db]
              end

              attr_reader :name, :srv_conn, :create_db, :dbms
              def initialize(name, srv_conn, dbms, create_db)
                fail ArgumentError, "DB name require" if name.to_s.empty?
                fail ArgumentError unless srv_conn.instance_of? DbConnection
                @name = name
                @srv_conn = srv_conn
                @dbms = dbms || fail(ArgumentError, "Require DBMS")
                @create_db = create_db || 'Y'
              end

              def fill_cs(cs)
                srv_conn.fill_cs(cs)
                cs.db = name
                cs.dbms = dbms
                cs.crsqldb = create_db
              end

              def to_connstr
                r = srv_conn.to_connstr
                r << "DB=\"#{name}\";"
                r << "DBMS=\"#{dbms}\";"
                r << "CrSQLDB=\"#{create_db}\";" if create_db
                r
              end
            end
          end

          include CommonDescriber
          include DescribeOptions

          def agent(str)
            @agent = Helpers::AgentConnection.parse_str(str) unless str.to_s.empty?
          end

          def claster(str)
            @claster = Helpers::ClasterConnection.parse_str(str)
            @claster.fill_cs(cs)
          end

          def db(str)
            @db = Helpers::Db.parse_str(str)
            @db.fill_cs(cs)
          end

          def schjobdn
            cs.schjobdn = 'Y'
          end

          def ib(&block)
            ib = super
            # FIXME: ib.server_agent = @agent || def_agent
            ib
          end

          def init_connection_string
            @connection_string = AssLauncher::Support::ConnectionString::Server\
              .new({srvr: 'localhost:1540', ref: ib_name.to_s})
            init_connections
            @connection_string
          end
          private :init_connection_string

          def def_db
            @db ||= Helpers::Db\
              .parse_str(AssTests.config.test_infobase_db\
                         + " --db-name #{ib_name}")
          end
          private :def_db

          def def_agent
            @agent ||= Helpers::AgentConnection\
              .parse_str(AssTests.config.test_infobase_server_agent)
          end
          private :def_agent

          def def_claster
            @claster ||= Helpers::ClasterConnection\
              .parse_str(AssTests.config.test_infobase_claster)
          end
          private :def_claster

          def init_connections
            def_db.fill_cs(cs)
            def_claster.fill_cs(cs)
          end
          private :init_connections
        end
      end

      def self.file(ib_name, &block)
        Describer::FileIb.new(ib_name).ib(&block)
      end

      def self.server(ib_name, &block)
        Describer::ServerIb.new(ib_name).ib(&block)
      end

      def self.external(ib_name, connection_string, &block)
        Describer::ExternalIb.new(ib_name, connection_string).ib(&block)
      end
    end

    def pull
      @pull ||= {}
    end
    private :pull

    def [](name)
      fail ArgumentError, "InfoBase `#{name}' not discribed" unless\
        pull.key? name
      ib = pull[name]
      ib.make unless ib.read_only?
      fail 'External infobse must be exists' if ib.read_only? && !ib.exists?
      ib
    end

    def describe(&block)
      fail ArgumentError, 'Require block' unless block_given?
      instance_eval(&block)
    end

    def add(ib)
      fail ArgumentError, "Ib #{ib.name} already described" if pull.key? ib.name
      pull[ib.name] = ib
    end

    def file(ib_name, &block)
      add(DSL.file(ib_name, &block))
    end

    def server(ib_name, &block)
      add(DSL.server(ib_name, &block))
    end

    def external(ib_name, connection_string, &block)
      add(DSL.external(ib_name, connection_string, &block))
    end
    extend self
  end
end
