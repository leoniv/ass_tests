require 'test_helper'

module AssTestsTest
  describe AssTests::VERSION do
    it 'test that it has a version number' do
      refute_nil ::AssTests::VERSION
    end
  end

  describe AssTests::InfoBases::InfoBase do
    it '.superclass' do
      AssTests::InfoBases::InfoBase.superclass.must_equal\
        AssMaintainer::InfoBase
    end

    def inst(**options)
      @inst ||= AssTests::InfoBases::InfoBase.new('name', Tmp::IB_CS, false,
                                                  **options)
    end

    after do
      begin
        FileUtils.rm_rf inst.connection_string.file if\
          inst.connection_string.file
      ensure
        @inst = nil
      end
    end

    it '#make' do
      seq = sequence('make')
      fixtures = mock
      ib = inst(:template => Fixtures::CF_FILE, :fixtures => fixtures)
      ib.expects(:load_template).in_sequence(seq)
      fixtures.expects(:execute).in_sequence(seq).with(ib)
      ib.make.must_equal ib
      ib.built?.must_equal true
    end

    it '#load_template fail' do
      e = proc {
        inst(:template => 'bad template').make
      }.must_raise RuntimeError
      e.message.must_match %r{Invalid template}
    end

    it '#load_template :dt mocked' do
      ib = inst(:template => Fixtures::DT_FILE)
      ib.expects(:load_dt)
      ib.load_template
    end

    it '#load_template :dt smoky' do
      inst(:template => Fixtures::DT_FILE).make.load_template.must_equal :dt
    end

    it '#load_template :src smoky' do
      inst(:template => File.new(Fixtures::XML_FILES))
        .make.load_template.must_equal :src
    end

    it '#load_template :src mocked' do
      ib = inst(:template => File.new(Fixtures::XML_FILES))
      ib.expects(:load_src)
      ib.load_template
    end

    it '#load_template :cf smoky' do
      inst(:template => Fixtures::CF_FILE)
        .make.load_template.must_equal :cf
    end

    it '#load_template :cf mocked' do
      ib = inst(:template => Fixtures::CF_FILE)
      ib.expects(:load_cf)
      ib.load_template
    end

    it '#template_type :cf' do
      inst(:template => Fixtures::CF_FILE).template_type.must_equal :cf
    end

    it '#template_type :dt' do
      inst(:template => Fixtures::DT_FILE).template_type.must_equal :dt
    end

    it '#template_type :src' do
      inst(:template => File.new(Fixtures::XML_FILES)).template_type.must_equal :src
    end

    it '#built? if not template loded false' do
      inst.expects(:exists?).returns(true)
      inst.built?.must_equal false
    end

    it '#built? if not fixtures loded false' do
      inst.expects(:exists?).returns(true)
      inst.expects(:template_loaded?).returns(true)
      inst.built?.must_equal false
    end

    it '#built? if not fixtures loded false' do
      inst.expects(:exists?).returns(true)
      inst.expects(:template_loaded?).returns(true)
      inst.expects(:fixtures_loaded?).returns(true)
      inst.built?.must_equal true
    end
  end
end
