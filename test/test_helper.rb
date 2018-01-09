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
  module Tmp
    extend AssLauncher::Api
    IB_NAME = self.name.gsub('::','_')
    IB_PATH = File.join(Dir.tmpdir, IB_NAME)
    IB_CS = cs_file file: IB_PATH

    EXTERNAL_IB_NAME = "external_#{IB_NAME}"
    EXTERNAL_IB_PATH = File.join(Dir.tmpdir, EXTERNAL_IB_NAME)
    EXTERNAL_IB_CS = cs_file file: EXTERNAL_IB_PATH

    EXTERNAL_IB = AssMaintainer::InfoBases::TestInfoBase.new(EXTERNAL_IB_NAME,
                                                   EXTERNAL_IB_CS, false)
    EXTERNAL_IB.make

    def self.do_at_exit
      EXTERNAL_IB.rm! :yes if EXTERNAL_IB.exists?
    end
  end

  AssMaintainer::InfoBases::TestInfoBase.configure do |conf|
    conf.platform_require = AssTestsTest::PLATFORM_REQUIRE
  end
end
