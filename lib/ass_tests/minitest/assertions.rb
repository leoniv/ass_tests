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
  module Minitest
    module Assertions
      # @api private
      module Comparable
        UNKNOWN_XML_TYPE = 'UNKNOWN_XML_TYPE'
        SRV_CONNECTORS = [AssLauncher::Enterprise::Ole::IbConnection,
          AssLauncher::Enterprise::Ole::ThickApplication]

        class ClientContext
          attr_reader :obj, :ole_connector
          def initialize(obj, ole_connector)
            @obj = obj
            @ole_connector = ole_connector
          end

          def string_internal
            fail NotImplementedError,
              "You should patch method #string_internal in class: #{self.class.name}"
          end

          def xml_type
            fail NotImplementedError,
              "You should patch method #xml_type in class: #{self.class.name}"
          end

          def as_string
            ole_connector.sTring obj
          end

          def make
            r = {}
            r[:as_string] = as_string
            r[:xml_type] = xml_type
            r[:as_string_internal] = string_internal
            r
          end
        end

        class SrvContext < ClientContext
          def string_internal
            ole_connector.ValueToStringInternal obj
          end

          def xml_type
            return UNKNOWN_XML_TYPE if ole_connector.xmlTypeOf(obj).nil?
            ole_connector.xmlTypeOf(obj).typeName
          end
        end

        def self.new(obj, ole_connector)
          return SrvContext.new(obj, ole_connector) if\
            SRV_CONNECTORS.include? ole_connector.class
          ClientContext.new(obj, ole_connector)
        end
      end

      def _assert_xml_type(exp, obj, mess = nil)
        act = Comparable.new(obj, ole_connector).xml_type
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
        mess = message(mess, ::Minitest::Assertions::E){diff exp_, act_}
        assert exp_ == act_, mess
      end

      def to_comparable(obj)
        return obj unless obj.is_a? WIN32OLE
        return obj.__real_obj__ if obj.__ruby__?
        Comparable.new(obj, ole_connector).make
      end
      private :to_comparable

      def not_comparable?(exp, act)
         ruby?(exp) ^ ruby?(act)
      end
      private :not_comparable?

      def ruby?(obj)
        !obj.is_a? WIN32OLE or obj.__ruby__?
      end
      private :ruby?

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
end

