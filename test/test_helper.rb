$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'

require 'ass_tests'
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
  end

  module Tmp
    extend AssLauncher::Api
    IB_NAME = self.name.gsub('::','_')
    IB_PATH = File.join(Dir.tmpdir, IB_NAME)
    IB_CS = cs_file file: IB_PATH
  end

  AssTests::InfoBases::InfoBase.configure do |conf|
    conf.platform_require = AssTestsTest::PLATFORM_REQUIRE
  end
end
