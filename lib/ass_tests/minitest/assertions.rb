module  Minitest
  class Assertion < Exception
    def location
      last_before_assertion = ""
      self.backtrace.reverse_each do |s|
        break if s =~ /in .(_?assert|_?refute|flunk|pass|fail|raise|must|wont)/
        last_before_assertion = s
      end
      last_before_assertion.sub(/:in .*$/, "")
    end
  end
end

module AssTests
  module Assertions
    class NotInitializedError < StandardError
      def message
        'External runtime does not initialized.'\
        ' AssTests::Assertions.init(ext_runtime) must be called before'\
        ' running any assertions'
      end
    end

    UNKNOWN_XML_TYPE = 'UNKNOWN_XML_TYPE'

    def self.init(ext_runtime)
      fail ArgumentError, 'Expected external runtime' if\
        ext_runtime.ole_type != :external
      @ext_runtime = ext_runtime
    end

    # Returns external runtime
    def self.ext_runtime
      @ext_runtime || fail(NotInitializedError)
    end

    def ext_ole_connector
      AssTests::Assertions.ext_runtime.ole_connector
    end

    def _assert_xml_type(exp, obj, mess = nil)
      act = xml_type_get(obj)
      mess = message(mess) do
        "Expected #{exp} xml type but #{act} given"
      end
      assert exp == act, mess
    end

    def _assert_ref_empty(obj, mess = nil)
      mess = message(mess) {"Ref must be empty"}
      assert obj.ref.IsEmpty, mess
    end

    def _refute_ref_empty(obj, mess = nil)
      mess = message(mess) {"Ref must not be empty"}
      refute obj.ref.IsEmpty, mess
    end

    def _assert_equal(exp, act, mess = nil)
      fail_not_comparable(exp, act) if not_comparable?(exp, act)
      exp_ = to_comparable(exp)
      act_ = to_comparable(act)
      mess = message(mess, Minitest::Assertions::E){diff exp_, act_}
      assert exp_ == act_, mess
    end

    def to_comparable(obj)
      return obj unless obj.is_a? WIN32OLE
      return obj.__real_obj__ if obj.__ruby__?
      # TODO: make comparsation ruby object from internal Ass string
      r = {}
      r[:as_string] = ext_ole_connector.sTring obj
      r[:xml_type] = xml_type_get(obj)
      r[:as_string_internal] = ext_ole_connector.ValueToStringInternal obj
      r
    end
    private :to_comparable

    def xml_type_get(obj)
      return UNKNOWN_XML_TYPE if ext_ole_connector.xmlTypeOf(obj).nil?
      ext_ole_connector.xmlTypeOf(obj).typeName
    end
    private :xml_type_get

    def not_comparable?(exp, act)
       is_ruby?(exp) ^ is_ruby?(act)
    end
    private :not_comparable?

    def is_ruby?(obj)
      !obj.is_a? WIN32OLE or obj.__ruby__?
    end
    private :is_ruby?

    def fail_not_comparable(exp, act)
      fail ArgumentError,
        "Not comparable types `#{exp.__real_object__.class}'"\
        " and `#{act.__real_object__.class}'"
    end
    private :fail_not_comparable
  end
end

