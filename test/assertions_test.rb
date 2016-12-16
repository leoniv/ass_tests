require 'test_helper'

module AssTestsTest
  require 'ass_tests/minitest/assertions'
  module Stubs
    class WIN32OLE

    end
  end
  describe AssTests::Assertions do
    include AssTests::Assertions
    it 'FIXME' do
      skip
    end

    it '#to_comparable_client_context fail' do
      skip
      e = proc {
      }.must_raise RuntimeError
      e.message.must_match %r{You should define own method #to_comparable_client_context}
    end

    it '#fail_not_comparable' do
      ruby_obj = :symbol
      ole_obj = stub :__real_obj__ => Stubs::WIN32OLE.new
      e = proc {
        fail_not_comparable(ruby_obj, ole_obj)
      }.must_raise ArgumentError
      e.message.must_match %r{Not comparable.*Symbol.*WIN32OLE}
    end
  end
end
