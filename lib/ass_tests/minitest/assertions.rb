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
      ::Minitest::Expectations.infect_an_assertion :_assert_xml_type, :must_be_xmltype

      def _assert_ref_empty(obj, mess = nil)
        mess = message(mess) {"Ref must be empty"}
        assert obj.ref.IsEmpty, mess
      end
      ::Minitest::Expectations.infect_an_assertion :_assert_ref_empty, :must_be_emptyref

      def _refute_ref_empty(obj, mess = nil)
        mess = message(mess) {"Ref must not be empty"}
        refute obj.ref.IsEmpty, mess
      end
      ::Minitest::Expectations.infect_an_assertion :_refute_ref_empty, :wont_be_emptyref

      def _assert_equal(exp, act, mess = nil)
        exp_ = to_comparable(exp)
        act_ = to_comparable(act)
        mess = message(mess, ::Minitest::Assertions::E){diff exp_, act_}
        assert exp_ == act_, mess
      end
      ## must_equal patch
      ::Minitest::Expectations.infect_an_assertion :_assert_equal, :must_equal

      def to_comparable(obj)
        return obj unless obj.is_a? WIN32OLE
        return obj.__real_obj__ if obj.__ruby__?
        return obj unless respond_to? :ole_connector
        Comparable.new(obj, ole_connector).make
      end
      private :to_comparable

      def ruby?(obj)
        !obj.is_a? WIN32OLE or obj.__ruby__?
      end
      private :ruby?

      def self.patch_minitest
        ::Minitest::Test.include self
      end
      patch_minitest

      # @todo extract to AssOle::Snippets::Shared::Type
      class AssTypeMaker
        attr_reader :type_name, :ole_connector
        def initialize(type_name, ole_connector)
          @type_name = type_name
          @ole_connector = ole_connector
        end

        def type_desc
          @type_desc ||= ole_connector.newObject('TypeDescription', type_name)
        end

        def make
          type_desc.Types.Get(0)
        end
      end

      # @todo extract to AssOle::Snippets::Shared::Type
      def ass_type(name)
        AssTypeMaker.new(name, ole_connector).make
      end

      class TypeDescriptionMatcher
        attr_reader :type_desc, :type_names, :ole_connector
        def initialize(type_names, type_desc, ole_connector)
          @ole_connector = ole_connector
          @type_desc = type_desc
          @type_names = type_names
        end

        def types_array(type_desc)
          r = []
          type_desc.Types.each do |t|
            r << t
          end
          r
        end
        private :types_array

        def to_comparable(array_of_ole)
          array_of_ole.map {|t|
            tc = Comparable.new(t, ole_connector).make
            "#{tc[:as_string]} #{tc[:as_string_internal]}"
              .force_encoding 'UTF-8'
          }.sort
        end
        private :to_comparable

        def expected_array_of_ole
          r = []
          type_names.each do |type|
            if type.to_s =~ %r{\.(ТипВсеСсылки|AllRefsType)\z}i
              r += types_array(ole_connector.send(type.to_s.split('.')[0]).send(type.to_s.split('.')[1]))
            else
              r += types_array(ole_connector.newObject('TypeDescription', type))
            end
          end
          r
        end

        def actual_arry_of_ole
          types_array(type_desc)
        end

        def expected_array
          to_comparable expected_array_of_ole
        end

        def expected
          expected_array.join("\n")
        end

        def actual
          actual_array.join("\n")
        end

        def actual_array
          to_comparable actual_arry_of_ole
        end

        def equal?
          expected == actual
        end

        def includes?
          includes == expected_array
        end

        def includes
          [actual & expected].sort
        end
      end

      # @param type_names [Array<Sting>] 1C type names. For +AllRefsType+
      #   use construction like +Documents.AllRefsType+ etc
      # @param type_desc [WIN32OLE] 1C +TypeDescription+ object
      # @param mess [String] message
      def _assert_type_equal(type_names, type_desc, mess = nil)
        matcher = TypeDescriptionMatcher
          .new(type_names, type_desc, ole_connector)

        mess_ = message(mess, ::Minitest::Assertions::E){
          "Expected types equal:\n#{diff matcher.expected, matcher.actual}"
        }

        assert matcher.equal?, mess_
      end
      ::Minitest::Expectations.infect_an_assertion :_assert_type_equal, :must_types_equal

      # @param obj [WIN32OLE] maust respond_to? :Type wich returns
      #  1C +TypeDescription+ object
      # @param type_names (see #_assert_type_equal)
      # @param mess (see #_assert_type_equal)
      def _assert_type_of(type_names, obj, mess = nil)
        _assert_type_equal(type_names, obj.Type, mess)
      end
      ::Minitest::Expectations.infect_an_assertion :_assert_type_of, :must_be_type_of

      # @param (see #_assert_type_equal)
      def _assert_type_includes(type_names, type_desc, mess = nil)
        matcher = TypeDescriptionMatcher.new(type_names, type_desc, ole_connector)
        mess = message(mess, ::Minitest::Assertions::E){
          "Expected types includes:\n#{diff matcer.expected, matcher.includes}"
        }

        assert matcher.includes?, mess
      end
      ::Minitest::Expectations.infect_an_assertion :_assert_type_includes, :must_have_types

      ## 1C object regex matcher

      def _assert_match(matcher, obj, mess = nil)
        return assert_match matcher, obj, mess unless obj.is_a? WIN32OLE
        return assert_match matcher, obj, mess unless respond_to? :ole_connector
        ole_str = ole_connector.sTring(obj)
        assert_match matcher, ole_str, mess
      end
      ::Minitest::Expectations.infect_an_assertion :_assert_match, :must_match
    end
  end
end

