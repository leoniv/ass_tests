require 'test_helper'
require 'ass_tests/info_bases'

AssTests::InfoBases.describe do
  file :empty_ib do
  # DescribeOptions
    template nil # Путь к шаблону ИБ
    fixtures nil # Объект реализующий интрфейс AssTests::FixturesInterface для
     # заполнения ИБ
    maker nil # Объект реализующий интерфейс AssTests::IbMakerInterface создающий
     # ИБ
    destroyer nil # Объект реализующий интерфейс AssTests::IbDistroyerInterface
     # уничтожающий ИБ
    platform_require ENV['ASS_PLATFORM']
    before_make ->(ib) { puts "Before make #{ib.name}"}
    after_make ->(ib) { puts "After make #{ib.name}"}
    before_rm ->(ib) { puts "Before rm #{ib.name}"}
    after_rm ->(ib) { puts "After rm #{ib.name}"}
  # CommonDescriber
    locale nil
    user 'name'
    password 'password'
  # FileIb
    directory File.expand_path('../../tmp', __FILE__)
  end

  server :empty_server_ib do
  # DescribeOptions
    template nil
    fixtures nil
    maker nil
    destroyer nil
    platform_require '~> 8.3.8'
    before_make nil
    after_make nil
    before_rm nil
    after_rm nil
  # CommonDescriber
    locale nil
    user 'name'
    password 'password'
  # ServerIb
    agent  "--host 'ahost:aport' --user 'aadmin' --password 'apassword'" # ENV['ASS_SERVER_AGENT']
    claster "--host 'chost:cport' --user 'cadmin' --password 'cpassword'" # ENV['ASS_CLASTER']
    db "--host 'dbhost:dbport' --dbms 'MSSQLServer' --db-name 'db_name' --user 'dbadmin' --password 'dbpassword' --create-db" # ENV['EMPTY_DATA_BASE']
    schjobdn # Запрет заданий см строка соединения
  end

  external :acc30, AssTestsTest::Tmp::EXTERNAL_IB_CS do
    platform_require '>= 8.3'
  end
end

module ExampleTest
  describe 'smoky test' do
    it 'empty_ib exists' do
      AssTests::InfoBases[:empty_ib].must_be_instance_of\
        AssTests::InfoBases::InfoBase
      AssTests::InfoBases[:empty_ib].is?(:file).must_equal true
      AssTests::InfoBases[:empty_ib].read_only?.must_equal false
    end

    it 'empty_server_ib exists' do
      proc {
        AssTests::InfoBases[:empty_server_ib].must_be_instance_of\
          AssTests::InfoBases::InfoBase
        AssTests::InfoBases[:empty_server_ib].is?(:server).must_equal true
        AssTests::InfoBases[:empty_server_ib].read_only?.must_equal false
      }.must_raise NotImplementedError
    end

    it 'acc30 exists' do
      AssTests::InfoBases[:acc30].must_be_instance_of\
        AssTests::InfoBases::InfoBase
      AssTests::InfoBases[:acc30].is?(:file).must_equal true
      AssTests::InfoBases[:acc30].read_only?.must_equal true
      AssTests::InfoBases[:acc30].platform_require.must_equal '>= 8.3'
    end
  end
end
