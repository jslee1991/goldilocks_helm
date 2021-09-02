# -*- coding: utf-8 -*-
require 'active_record/connection_adapters/abstract_adapter'
require 'arel/visitors/bind_visitor'

module Arel
  module Visitors
    class Goldilocks < Arel::Visitors::ToSql
    end # class Goldilocks
  end # module Visitors
end # module Arel

module ActiveRecord
  class Base
    def self.goldilocks_connection(config)
      begin
        require 'goldilocks' unless defined? GOLDILOCKS
      rescue LoadError
        raise LoadError, "Failed to load GOLDILOCKS Ruby driver."
      end

      config = config.symbolize_keys

      begin
        dsn  = config[:dsn]
        host = config[:host]
        port = config[:port]
        uid  = config[:uid]
        pwd  = config[:pwd]
        opt  = config[:option]

        conn_str = ''
        conn_str += "DSN=" +  dsn  + ";" unless dsn.nil?
        conn_str += "HOST=" + host + ";" unless host.nil?
        conn_str += "PORT=" + port + ";" unless port.nil?
        conn_str += "UID=" +  uid  + ";" unless uid.nil?
        conn_str += "PWD=" +  pwd  + ";" unless pwd.nil?
        conn_str += opt + ";" unless opt.nil?
  
        connection = GOLDILOCKS::Database.new.drvconnect(conn_str)
      rescue StandardError => connect_err
        error_msg = GOLDILOCKS::Database.error
        raise "Failed to connect due to: #{error_msg}"
      end

      if connection
        ConnectionAdapters::GoldilocksAdapter.new(connection, logger, config)
      else
        # If the connection failure was not caught previoulsy, it raises a Runtime error
        raise "An unexpected error occured during connect"
      end
    end # goldilocks_connection
  end # class Base

  module ConnectionAdapters #:nodoc:
    class SchemaCreation < AbstractAdapter::SchemaCreation
      private

      def visit_AddColumn(o)
        sql_type = type_to_sql(o.type.to_sym, o.limit, o.precision, o.scale)
        sql = "ADD COLUMN #{quote_column_name(o.name)} #{sql_type}"
        add_column_options!(sql, column_options(o))
      end
    end # class SchemaCreation

    class GoldilocksAdapter < AbstractAdapter

      def initialize(connection, logger, config)
        super(connection, logger, config)

        @config = config

#        if self.class.type_cast_config_to_boolean(config.fetch(:prepared_statements) { true })
#          @prepared_statements = true
#          @visitor = Arel::Visitors::Goldilocks.new self
#        else
          @visitor = unprepared_visitor
#        end
      end

      def schema_creation
        SchemaCreation.new self
      end

      def adapter_name
        'goldilocks'
      end

      def version
        @version = "21.1.5"
      end

      class BindSubstitution < Arel::Visitors::Goldilocks
        include Arel::Visitors::BindVisitor
      end

      def supports_migrations?
        true
      end

      def supports_primary_key?
        true
      end

      def supports_ddl_transactions?
        true
      end

      def supports_savepoints?
        true
      end

      def supports_index_sort_order?
        true
      end

      def supports_transaction_isolation?
        true
      end

      # QUOTING ==================================================

      def quote_string(string)
        string.gsub(/'/, "''")
      end

      # REFERENTIAL INTEGRITY ====================================

      # CONNECTION MANAGEMENT ====================================

      def active?
        @connection.connected?
      end

      def reconnect!
        disconnect!
        @connection =
          if @config.key?(:dsn)
            goldilocks.connect(@config[:dsn], @config[:username], @config[:password])
          else
            goldilocks::Database.new.drvconnect(@config[:driver])
          end
        configure_time_options(@connection)
        super
      end
      alias reset! reconnect!

      def disconnect!
        @connection.disconnect if @connection.connected?
      end

      # DATABASE STATEMENTS ======================================

      def select(sql, name = nil, binds = [])
        exec_query(sql, name, binds)
      end

      def select_rows(sql, name = nil, binds = [])
        execute(sql, name, binds).to_a
      end

      def execute(sql, name = nil, binds = [])
        log(sql, name) do
          if without_prepared_statement?(binds)
            @connection.do(sql)
          else
            @connection.do(sql, *binds.map { |col, val| type_cast(val, col) })
          end
        end
      end

      def exec_query(sql, name = 'SQL', binds = [], prepare: false)
        log(sql, name) do
          stmt =
            if without_prepared_statement?(binds)
              @connection.run(sql)
            else
              @connection.run(sql, *binds.map { |col, val| type_cast(val, col) })
            end

          columns = stmt.columns
          values  = stmt.to_a
          stmt.drop

          column_names = columns.keys.map { |key| key.downcase }
          ActiveRecord::Result.new(column_names, values)
        end
      end

      def exec_delete(sql, name, binds)
        execute(sql, name, binds)
      end
      alias exec_update exec_delete

      def exec_insert(sql, name = nil, binds = [], pk = nil, sequence_name = nil)
        sql = "#{sql} RETURNING #{quote_column_name(pk)}" if pk
        super
      end

      def begin_db_transaction
        @connection.autocommit = false
      end

      def begin_isolated_db_transaction(isolation)
        execute "SET TRANSACTION ISOLATION LEVEL #{transaction_isolation_levels.fetch(isolation)}"
        begin_db_transaction
      rescue
        # Transactions aren't supported
      end

      def commit_db_transaction
        @connection.commit
        @connection.autocommit = true
      end

      def exec_rollback_db_transaction
        @connection.rollback
        @connection.autocommit = true
      end

      def create_savepoint
        execute("SAVEPOINT #{current_savepoint_name}")
      end

      def rollback_to_savepoint
        execute("ROLLBACK TO SAVEPOINT #{current_savepoint_name}")
      end

      def release_savepoint
        execute("RELEASE SAVEPOINT #{current_savepoint_name}")
      end

      # SCHEMA STATEMENTS ========================================

      def native_database_types
        {
          :primary_key => "INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY",
          :binary      => { :name => "LONG VARBINARY" },
          :bigint      => { :name => "BIGINT"},
          :boolean     => { :name => "BOOLEAN" },
          :char        => { :name => "CHAR" },
          :date        => { :name => "DATE" },
          :datetime    => { :name => "DATE" },
          :decimal     => { :name => "NUMBER" },
          :double      => { :name => "DOUBLE" },
          :float       => { :name => "FLOAT" },
          :integer     => { :name => "INTEGER" },
          :rowid       => { :name => "ROWID" },
          :string      => { :name => "VARCHAR", :limit => 255 },
          :text        => { :name => "LONG VARCHAR" },
          :time        => { :name => "DATE" },
          :timestamp   => { :name => "DATE" }
        }
      end

      def tables(_name = nil)
        tables = []
        stmt = @connection.run("SELECT TABLE_NAME FROM USER_TABLES")

        if(stmt)
          begin
            while tab = stmt.fetch
              tables << tab[0].downcase
            end
          rescue StandardError => fetch_error
            error_msg = stmt.error
            if error_msg && !error_msg.empty?
              raise "Failed to retrieve table metadata during fetch: #{error_msg}"
            else
              error_msg = "An unexpected error occurred during retrieval of table metadata"
              error_msg = error_msg + ": #{fetch_error.message}" if !fetch_error.message.empty?
              raise error_msg
            end
          ensure
            stmt.drop if stmt
          end
        else
          error_msg = @connection.error
          if error_msg && !error_msg.empty?
            raise "Failed to retrieve tables metadata due to error: #{error_msg}"
          else
            raise StandardError.new('An unexpected error occurred during retrieval of table metadata')
          end
        end

        return tables
      end

      def columns(table_name, _name = nil)
        table_name = table_name.to_s.upcase
        return [] if table_name.strip.empty?

        columns = []
        stmt = @connection.columns(table_name)

        if(stmt)
          begin
            while col = stmt.fetch
              column_name    = col[3].downcase
              column_default = col[12]
              column_type    = col[5].downcase
              column_length  = col[6]
              column_scale   = col[8]

              unless column_type =~ /long|native|boolean|rowid|date|time|interval/i
                if column_scale.nil?
                  column_type << "(#{column_length})"
                else
                  column_type << "(#{column_length},#{column_scale})"
                end
              end

              column_nullable = (col[10] == 1) ? true : false

              columns << Column.new( column_name, column_default, column_type, column_nullable )
            end
          rescue StandardError => fetch_error
            error_msg = stmt.error
            if error_msg && !error_msg.empty?
              raise "Failed to retrieve column metadata during fetch: #{error_msg}"
            else
              error_msg = "An unexpected error occurred during retrieval of column metadata"
              error_msg = error_msg + ": #{fetch_error.message}" if !fetch_error.message.empty?
              raise error_msg
            end
          ensure
            stmt.drop if stmt
          end
        else
          error_msg = @connection.error
          if error_msg && !error_msg.empty?
            raise "Failed to retrieve column metadata due to error: #{error_msg}"
          else
            raise StandardError.new('An unexpected error occurred during retrieval of column metadata')
          end
        end

        return columns
      end

      def primary_key(table_name)
        pk_name = nil
        stmt = @connection.primary_keys(table_name.to_s.upcase)

        if(stmt) 
          begin
            if ( pk_index_row = stmt.fetch )
              pk_name = pk_index_row[3].downcase
            end
          rescue StandardError => fetch_error # Handle driver fetch errors
            error_msg = stmt.error
            if error_msg && !error_msg.empty?
              raise "Failed to retrieve primarykey metadata during fetch: #{error_msg}"
            else
              error_msg = "An unexpected error occurred during retrieval of primary key metadata"
              error_msg = error_msg + ": #{fetch_error.message}" if !fetch_error.message.empty?
              raise error_msg
            end
          ensure
            stmt.drop if stmt
          end
        else
          error_msg = @connection.error
          if error_msg && !error_msg.empty?
            raise "Failed to retrieve primary key metadata due to error: #{error_msg}"
          else
            raise StandardError.new('An unexpected error occurred during primary key retrieval')
          end
        end

        return pk_name
      end

      def current_database
        database_metadata.database_name.strip
      end

      def quoted_columns_for_index(column_names, options = {})
        option_strings = Hash[column_names.map {|name| [name, '']}]
        option_strings = add_index_sort_order(option_strings, column_names, options)

        column_names.map {|name| quote_column_name(name).to_s + option_strings[name]}
      end

    end # class GoldilocksAdapter
  end # ConnectionAdapters
end # module ActiveRecord
