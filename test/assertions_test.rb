require 'test_helper'

module AssTestsTest
  require 'ass_tests/minitest/assertions'
  describe AssTests::Assertions do
    it 'FIXME' do
      skip
    end

    it '#to_comparable fail' do
      skip
      e = proc {
        skip
      }.must_raise AssTests::Assertions::InvalidOleConnectorError
      e.message.must_equal ''
    end
  end
end
