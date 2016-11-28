module AssTest
  module OleFixt
    class Abstract
      attr_reader :ole_connector
      def initialize(ole_connector)
        @ole_connector = ole_connector
      end

      def fill(obj, **fields)
        fields.each do |f, v|
          obj.send("#{f}=".to_sym, v)
        end
        obj
      end
      private :fill

      def fill_table(obj, table_name, rows = [])
        table = obj.send(table_name.to_sym)
        rows.each do |row|
          fill(table.add, **row)
        end
        table
      end
      private :fill_table
    end
    def self.catalog(ole_connector)
      Catalog.new(ole_connector)
    end
    class Catalog < Abstract
      def new_(method, md_name, fields, tables)
        r = ole_connector.catalogs.send(md_name.to_sym).send(method)
        fill(r, fields)
        tables.each do |table, rows|
          fill_table(r, table, rows)
        end
        fill(r, fields)
        yield r if block_given?
        r.write
        r.ref
      end
      private :new_
      def new_item(md_name, fields = {}, tables = {}, &block)
        new_(:createItem, md_name, fields, tables, &block)
      end
      def new_folder(md_name, fields = {}, tables = {}, &block)
        new_(:createFolder, md_name, fields, tables, &block)
      end
    end
  end
end
