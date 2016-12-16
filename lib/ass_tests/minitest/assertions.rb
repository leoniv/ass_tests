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
    UNKNOWN_XML_TYPE = 'UNKNOWN_XML_TYPE'

    GOOD_OLE_CONNECTORS = [
      AssLauncher::Enterprise::Ole::IbConnection,
      AssLauncher::Enterprise::Ole::ThickApplication
    ]
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

      return to_comparable_srv_context(obj) if\
        GOOD_OLE_CONNECTORS.include? ole_connector.class
      to_comparable_client_context(obj)
    end
    private :to_comparable

    def to_comparable_client_context(obj)
      fail 'You should define own method #to_comparable_client_context'\
        ' and returns #new_comparable Hash'
    end
    private :to_comparable_client_context

    def to_comparable_srv_context(obj)
      new_comparable ole_connector.sTring(obj),
        xml_type_get(obj),
        ole_connector.ValueToStringInternal(obj)
    end
    private :to_comparable_srv_context

    def new_comparable(as_string, xml_type, as_string_internal)
      r = {}
      r[:as_string] = as_string
      r[:xml_type] = xml_type
      r[:as_string_internal] = as_string_internal
      r
    end
    private :new_comparable

    def xml_type_get(obj)
      return UNKNOWN_XML_TYPE if ole_connector.xmlTypeOf(obj).nil?
      ole_connector.xmlTypeOf(obj).typeName
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
        "Not comparable types `#{not_comparable_class exp}'"\
        " and `#{not_comparable_class act}'"
    end
    private :fail_not_comparable

    def not_comparable_class(obj)
      return obj.__real_obj__.class if obj.respond_to? :__real_obj__
      obj.class
    end
    private :not_comparable_class
  end
end

