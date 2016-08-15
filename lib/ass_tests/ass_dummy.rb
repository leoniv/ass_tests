module AssTests
  module AssDummy
    def ass_dummy(obj)
      eval("#{obj}").new
    end
    class Query
      attr_accessor :МенеджерВременныхТаблиц, :TempTablesManager,
        :Параметры, :Parameters,
        :Текст, :Text
      attr_reader :Выполнить, :Execute,
        :ВыполнитьПакет, :ExecuteBatch,
        :ВыполнитьПакетСПромежуточнымиДанными, :ExecuteBatchWithIntermediateData,
        :НайтиПараметры, :FindParameters,
        :УстановитьПараметр, :SetParameter
    end

    class QueryResult
      attr_reader :Колонки, :Columns,
        :Выбрать, :Select,
        :Выгрузить, :Unload,
        :Пустой, :IsEmpty
    end
  end
end
