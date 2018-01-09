require 'test_helper'

module AssTestsTest
  describe AssTests::VERSION do
    it 'test that it has a version number' do
      refute_nil ::AssTests::VERSION
    end
  end
end
