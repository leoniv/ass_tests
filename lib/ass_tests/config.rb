module AssTests
  require 'ass_launcher'
  require 'tmpdir'
  TEST_INFOBASE_DIRECTORY = Dir.tmpdir
  ASS_PLATFORM_REQUIRE = ENV['ASS_PLATFORM_REQUIRE'] || '> 0'
  TEST_INFOBASE_DB = ENV['TEST_INFOBASE_DB'] ||\
    '--dbms MSSQLServer --host 127.0.0.1,1433 --user USR1CV8'
  TEST_INFOBASE_CLASTER = ENV['TEST_INFOBASE_CLASTER'] ||\
    '--host 127.0.0.1:1541'
  TEST_INFOBASE_SERVER_AGENT = ENV['TEST_INFOBASE_SERVER_AGENT'] ||\
    '--host 127.0.0.1:1540'

  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  class Config
    attr_writer :platform_require
    def platform_require
      @platform_require ||= ASS_PLATFORM_REQUIRE
    end

    attr_writer :test_infobase_directory
    def test_infobase_directory
      @test_infobase_directory ||= TEST_INFOBASE_DIRECTORY
    end

    attr_writer :test_infobase_db
    def test_infobase_db
      @test_infobase_db ||= TEST_INFOBASE_DB
    end

    attr_writer :test_infobase_claster
    def test_infobase_claster
      @test_infobase_claster ||= TEST_INFOBASE_CLASTER
    end

    attr_writer :test_infobase_server_agent
    def test_infobase_server_agent
      @test_infobase_server_agent ||= TEST_INFOBASE_SERVER_AGENT
    end
  end
end
