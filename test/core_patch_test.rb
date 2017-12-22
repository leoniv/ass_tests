require 'test_helper'

module AssTestsTest
  describe StandardError do
    HRESULT_ASCII_MESSAGE =
      "unknown property or method: `Write'\n"\
      "Текст по русски"\
      "HRESULT error code:0x80020006\n"\
      "      \xCD\xE5\xE8\xE7\xE2\xE5\xF1\xF2\xED\xEE\xE5 \xE8\xEC\xFF.\n"
        .force_encoding('ASCII-8BIT')

    it 'NoMethodError message patched' do
      inst = NoMethodError.new HRESULT_ASCII_MESSAGE
      inst.message.must_equal "unknown property or method: `Write'\n"\
                              "Текст по русски"\
                              "HRESULT error code:0x80020006"\
    end

    it 'WIN32OLERuntimeError message patched' do
      inst = WIN32OLERuntimeError.new HRESULT_ASCII_MESSAGE
      inst.message.must_equal "unknown property or method: `Write'\n"\
                              "Текст по русски"\
                              "HRESULT error code:0x80020006"\
    end
  end
end
