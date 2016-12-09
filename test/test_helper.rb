$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
at_exit do
  AssTestsTest::Tmp.do_at_exit
end
require 'simplecov'

require 'ass_tests'
require 'ass_tests/info_bases'
require 'minitest/autorun'
require 'mocha/mini_test'

module AssTestsTest
  PLATFORM_REQUIRE = '~> 8.3.9.0'
  module Fixtures
    PATH = File.expand_path('../fixtures', __FILE__)

    XML_FILES = File.join PATH, 'xml_files'
    fail unless File.directory? XML_FILES

    CF_FILE = File.join PATH, 'ib.cf'
    fail unless File.file? CF_FILE

    DT_FILE = File.join PATH, 'ib.dt'
    fail unless File.file? DT_FILE

    HELLO_EPF = File.join PATH, 'hello.epf'
    fail unless File.file? HELLO_EPF

    CATALOG_CF = File.join PATH, 'catalog.cf'
    fail unless File.file? CATALOG_CF
  end

  module Tmp
    extend AssLauncher::Api
    IB_NAME = self.name.gsub('::','_')
    IB_PATH = File.join(Dir.tmpdir, IB_NAME)
    IB_CS = cs_file file: IB_PATH

    EXTERNAL_IB_NAME = "external_#{IB_NAME}"
    EXTERNAL_IB_PATH = File.join(Dir.tmpdir, EXTERNAL_IB_NAME)
    EXTERNAL_IB_CS = cs_file file: EXTERNAL_IB_PATH

    EXTERNAL_IB = AssTests::InfoBases::InfoBase.new(EXTERNAL_IB_NAME,
                                                   EXTERNAL_IB_CS, false)
    EXTERNAL_IB.make

    def self.do_at_exit
      EXTERNAL_IB.rm! :yes if EXTERNAL_IB.exists?
    end
  end

  AssTests::InfoBases::InfoBase.configure do |conf|
    conf.platform_require = AssTestsTest::PLATFORM_REQUIRE
  end
end
