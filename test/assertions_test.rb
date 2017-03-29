require 'test_helper'

module AssTestsTest
  require 'ass_tests/minitest/assertions'
  module Stubs
    class WIN32OLE

    end
  end

  describe AssTests::Minitest::Assertions do
    include AssTests::Minitest::Assertions

    it '#to_comparable unless WIN32OLE' do
      to_comparable(:ruby_symbol).must_equal :ruby_symbol
    end

    def win32ole
      Class.new(WIN32OLE) do
        def initialize(*args)

        end
      end.new
    end

    def test_case_stub
      @test_case_stub ||= Class.new do
        include AssTests::Minitest::Assertions
        include Minitest::Assertions
      end.new
    end

    def comparable_context
      AssTests::Minitest::Assertions::Comparable::ClientContext.new(nil, nil)
    end

    it '#_assert_xml_type' do
      skip
#      actual = mock
#
#      comparable = mock
#      comparable.responds_like comparable_context
#      comparable.expects(:xml_type).returns(:actual)
#
#      AssTests::Minitest::Assertions::Comparable.expects(:new).with(:obj, :ole_connector)
#        .returns(comparable)
#
#      test_case_stub.expects(:ole_connector).returns(:ole_connector)
#
##      test_case_stub.expects(:assert)
##        .with(:true, 'Expected exp xml type but actual given').returns(:assert)
##
#      test_case_stub._assert_xml_type(:exp, :obj, :mess).must_equal true
    end

    it '#to_comparable if __ruby__?' do
      obj = win32ole
      obj.expects(:__ruby__?).returns(true)
      obj.expects(:__real_obj__).returns(:real_obj)
      to_comparable(obj).must_equal :real_obj
    end

    it '#to_comparable if 1C WIN32OLE' do
      comparable = mock
      comparable.responds_like AssTests::Minitest::Assertions::Comparable::ClientContext.new(nil, nil)
      comparable.expects(:make).returns(:comparable)
      obj = win32ole
      obj.expects(:__ruby__?).returns(false)
      obj.expects(:__real_obj__).never
      expects(:ole_connector).returns(:ole_connector)
      AssTests::Minitest::Assertions::Comparable
        .expects(:new).with(obj, :ole_connector).returns(comparable)
      to_comparable(obj).must_equal :comparable
    end

    describe AssTests::Minitest::Assertions::Comparable do
      include AssLauncher::Api

      def external_ole
        ole :external
      end

      def thick_ole
        ole :thick
      end

      def thin_ole
        ole :thin
      end

      it '.new' do
        self.class.desc.new(:value, external_ole)
          .must_be_instance_of self.class.desc::SrvContext
        self.class.desc.new(:value, thick_ole)
          .must_be_instance_of self.class.desc::SrvContext
        self.class.desc.new(:value, thin_ole)
          .must_be_instance_of self.class.desc::ClientContext
      end
    end

    describe AssTests::Minitest::Assertions::Comparable::ClientContext do
      it '#string_internal fail NotImplementedError' do
        e = proc {
          inst.string_internal
        }.must_raise NotImplementedError
        e.message.must_match %r{You should patch method #string_internal in class:}
      end

      it '#xml_type fail NotImplementedError' do
        e = proc {
          inst.xml_type
        }.must_raise NotImplementedError
        e.message.must_match %r{You should patch method #xml_type in class:}
      end

      it '#initialize' do
        inst(:obj, :ole_connector)
        inst.obj.must_equal :obj
        inst.ole_connector.must_equal :ole_connector
      end

      it '#as_string' do
        ole_connector = mock
        ole_connector.expects(:sTring).with(:obj).returns('as_string')
        inst(:obj, ole_connector).as_string.must_equal 'as_string'
      end

      def inst(obj = nil, ole_connector = nil)
        @inst ||= self.class.desc.new(obj, ole_connector)
      end

      it '#make' do
        inst.expects(:as_string).returns('as_string')
        inst.expects(:xml_type).returns('xml_type')
        inst.expects(:string_internal).returns('string_internal')
        expected = {as_string: 'as_string', xml_type: 'xml_type', as_string_internal: 'string_internal'}
        inst.make.must_equal expected
      end
    end

    describe AssTests::Minitest::Assertions::Comparable::SrvContext do
      def inst(obj, ole_connector)
        @inst ||= self.class.desc.new(obj, ole_connector)
      end

      it '#string_internal' do
        ole_connector = mock
        ole_connector.expects(:ValueToStringInternal).with(:obj).returns('string_internal')
        inst(:obj, ole_connector).string_internal.must_equal 'string_internal'
      end

      it '#xml_type UNKNOWN_XML_TYPE' do
        ole_connector = mock
        ole_connector.expects(:xmlTypeOf).with(:obj).returns(nil).once
        inst(:obj, ole_connector).xml_type.must_equal\
          AssTests::Minitest::Assertions::Comparable::UNKNOWN_XML_TYPE
      end

      it '#xml_type UNKNOWN_XML_TYPE' do
        xml_type = stub typeName: 'xml_type'
        ole_connector = mock
        ole_connector.expects(:xmlTypeOf).with(:obj).returns(xml_type).twice
        inst(:obj, ole_connector).xml_type.must_equal 'xml_type'
      end
    end
  end
end
