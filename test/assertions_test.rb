require 'test_helper'

module AssTestsTest
  require 'ass_tests/minitest/assertions'
  describe AssTests::Assertions do
    it 'FIXME' do
      skip
    end

    it '.ext_runtime fail' do
      e = proc {
        AssTests::Assertions.ext_runtime
      }.must_raise AssTests::Assertions::NotInitializedError
      e.message.must_equal ''
    end
  end
end
