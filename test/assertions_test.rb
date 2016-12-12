require 'test_helper'

module AssTestsTest
  require 'ass_tests/minitest/assertions'
  describe AssTests::Assertions do
    it 'FIXME' do
      skip
    end

    it '#to_comparable_client_context fail' do
      skip
      e = proc {
      }.must_raise RuntimeError
      e.message.must_match %r{You should define own method #to_comparable_client_context}
    end
  end
end
