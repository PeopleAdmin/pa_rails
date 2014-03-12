require 'cases/helper'
require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapterTest < ActiveRecord::TestCase
      attr_reader :adapter, :table_name, :view_name

      def setup
        @adapter = ActiveRecord::Base.connection
        @table_name = 'StructureTestTable'
        @view_name = 'StructureTestView'
        assert adapter.is_a?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        create_table
        insert_table_rows
        create_view
      end

      def teardown
        drop_table
        drop_view
      end

      def test_structure_dump_includes_tables
        assert_match(/CREATE TABLE `#{table_name}`/i, adapter.structure_dump)
      end

      def test_structure_dump_includes_views
        assert_match(/CREATE .+ VIEW `#{view_name}`/i, adapter.structure_dump)
      end

      def test_structure_dump_strips_extraneous_auto_increment_values
        assert_no_match(/AUTO_INCREMENT=\d+/, adapter.structure_dump)
      end

      private
        def create_table
          adapter.execute("CREATE TABLE `#{table_name}` (id int primary key auto_increment, data int)")
        end

        def insert_table_rows(count=2)
          count.times do |i|
            adapter.execute("INSERT INTO `#{table_name}` (data) values (#{i})")
          end
        end

        def create_view
          adapter.execute("CREATE VIEW `#{view_name}` AS SELECT * FROM #{table_name}")
        end

        def drop_table
          adapter.execute("DROP TABLE IF EXISTS `#{table_name}`")
        end

        def drop_view
          adapter.execute("DROP VIEW IF EXISTS `#{view_name}`")
        end
    end
  end
end
