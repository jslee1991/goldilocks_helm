package org.hibernate.dialect;

import org.hibernate.MappingException;
import org.hibernate.cfg.Environment;
import org.hibernate.dialect.Dialect;
import org.hibernate.dialect.function.NoArgSQLFunction;
import org.hibernate.dialect.function.StandardSQLFunction;
import org.hibernate.dialect.function.VarArgsSQLFunction;

import org.hibernate.dialect.pagination.AbstractLimitHandler;
import org.hibernate.dialect.pagination.LimitHandler;
import org.hibernate.dialect.pagination.LimitHelper;

import org.hibernate.engine.spi.RowSelection;
import org.hibernate.internal.util.StringHelper;
import org.hibernate.sql.ANSICaseFragment;
import org.hibernate.sql.ANSIJoinFragment;
import org.hibernate.sql.CaseFragment;
import org.hibernate.sql.JoinFragment;
import org.hibernate.type.StandardBasicTypes;

import java.sql.CallableStatement;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.List;

/**
 * An SQL dialect for SUNJESOFT Goldilocks (20c and later).
 * 
 * @author lkh
 * 
 * @see
 * << Modification Information >>
 * 
 */
class GoldilocksLimitHandler extends AbstractLimitHandler implements LimitHandler {

    public GoldilocksLimitHandler(String sql, RowSelection selection) {
        super( sql, selection );
    }
    
    @Override
    public boolean supportsLimit() {
		return true;
	}

    @Override
    public String getProcessedSql() {
        if( LimitHelper.useLimit(  this, selection ) == true ) {
            boolean sHasOffset = LimitHelper.hasFirstRow( selection );
            return sql + ( (sHasOffset == true) ? " limit ?,?" : " limit ?" );
        }
        else {
            return sql;
        }
	}
}

public class GoldilocksDialect extends Dialect {
    private static final Pattern SQL_STATEMENT_TYPE_PATTERN = Pattern.compile("^\\s*(select|insert|update|delete)\\s+.*?");

    /**
     * Constructs a GoldilocksDialect
     */
    public GoldilocksDialect() {
        super();
        registerCharacterTypeMappings();
        registerNumericTypeMappings();
        registerDateTimeTypeMappings();
        
        registerFunctions();
        
        registerDefaultProperties();
    }
    
    protected void registerCharacterTypeMappings() {
        registerColumnType( Types.BOOLEAN, "boolean" );
        
        registerColumnType( Types.CHAR, 2000, "char($l)" );
        registerColumnType( Types.VARCHAR, 4000, "varchar($l)" );
        registerColumnType( Types.LONGVARCHAR, "long varchar" );
       
        registerColumnType( Types.BINARY, "binary" );
        registerColumnType( Types.VARBINARY, "varbinary" );
        registerColumnType( Types.VARBINARY, 4000, "varbinary($l)" );
        registerColumnType( Types.LONGVARBINARY, "long varbinary" );
    }
    
    protected void registerNumericTypeMappings() {
        registerColumnType( Types.SMALLINT, "smallint" );
        registerColumnType( Types.INTEGER, "integer" );
        registerColumnType( Types.BIGINT, "bigint" );
        
        registerColumnType( Types.REAL, "real" );
        registerColumnType( Types.DOUBLE, "double" );
        
        registerColumnType( Types.FLOAT, "float" );
        registerColumnType( Types.FLOAT, "float($p)" );
        
        registerColumnType( Types.NUMERIC, "numeric" );
        registerColumnType( Types.NUMERIC, "numeric($p)" );
        registerColumnType( Types.NUMERIC, "numeric($p, $s)" );
        
        registerColumnType( Types.ROWID, "rowid" );
    }
    
    protected void registerDateTimeTypeMappings() {
        registerColumnType( Types.DATE, "date" );
        registerColumnType( Types.TIME, "time" );
        registerColumnType( Types.TIMESTAMP, "timestamp" );
    }

    protected void registerFunctions() {
        /**
         *  JDBC      /   JAVA             / BasicTypeRegistry key
         *  CHAR      /   char, Character  / char, Character
         *  VARCHAR   /   String           / string, String
         *  BINARY    /  
         *  VARBINARY /   byte[]           / binary, byte[]
         *  SMALLINT  /   short, Short     / short, Short
         *  INTEGER   /   int, Integer     / int, Integer
         *  BIGINT    /   long, Long       / long, Long
         *  DOUBLE    /   double, Double   / double, Double
         *  FLOAT     /   float, Float     / float, Float
         *  NUMERIC   /   BigInteger, BigDecimal / big_integer, BigInteger, big_decimal, BigDecimal
         */
        
        /* One Parameter String dialect functions */
        registerFunction( "ascii", new StandardSQLFunction( "ascii", StandardBasicTypes.LONG ) );               /* NUMBER */
        registerFunction( "bit_length", new StandardSQLFunction( "bit_length", StandardBasicTypes.LONG ) );     /* NATIVE_BIGINT */
        registerFunction( "byte_length", new StandardSQLFunction( "byte_length", StandardBasicTypes.LONG ) );   /* NATIVE_BIGINT */
        registerFunction( "char_length", new StandardSQLFunction( "char_length", StandardBasicTypes.LONG ) );   /* NATIVE_BIGINT */
        registerFunction( "chr", new StandardSQLFunction( "chr", StandardBasicTypes.CHARACTER ) );              /* VARCHAR */
        registerFunction( "decode", new StandardSQLFunction( "decode", StandardBasicTypes.STRING ) );           /* VARCHAR */
        registerFunction( "length", new StandardSQLFunction( "length", StandardBasicTypes.LONG ) );             /* NATIVE_BIGINT */     
        registerFunction( "lengthb", new StandardSQLFunction( "lengthb", StandardBasicTypes.LONG ) );           /* NATIVE_BIGINT */
        registerFunction( "lower", new StandardSQLFunction( "lower", StandardBasicTypes.STRING ) );             /* VARCHAR */
        registerFunction( "octet_length", new StandardSQLFunction( "octet_length", StandardBasicTypes.LONG ) ); /* NATIVE_BIGINT */
        registerFunction( "upper", new StandardSQLFunction( "upper", StandardBasicTypes.STRING ) );             /* VARCHAR */  
        registerFunction( "unhex", new StandardSQLFunction( "unhex", StandardBasicTypes.BINARY ) );             /* BINARY */
        
        /* Multi-Parameter String dialect functions */
        registerFunction( "concat", new VarArgsSQLFunction( StandardBasicTypes.STRING, "", "||", "" ) );
        registerFunction( "concatenate", new VarArgsSQLFunction( StandardBasicTypes.STRING, "", "||", "" ) );
        registerFunction( "lpad", new StandardSQLFunction( "lpad", StandardBasicTypes.STRING ) );
        registerFunction( "ltrim", new StandardSQLFunction( "ltrim", StandardBasicTypes.STRING ) );
        registerFunction( "overlay", new StandardSQLFunction( "overay" ) );
        registerFunction( "rpad", new StandardSQLFunction( "rpad", StandardBasicTypes.STRING ) );
        registerFunction( "rtrim", new StandardSQLFunction( "rtrim", StandardBasicTypes.STRING ) );
        registerFunction( "split_part", new StandardSQLFunction( "split_part", StandardBasicTypes.STRING ) );
        registerFunction( "substr", new StandardSQLFunction( "substr", StandardBasicTypes.STRING ) );
        registerFunction( "substrb", new StandardSQLFunction( "substrb", StandardBasicTypes.STRING ) );
        registerFunction( "substring", new StandardSQLFunction( "substring", StandardBasicTypes.STRING ) );
        registerFunction( "translate", new StandardSQLFunction( "translate", StandardBasicTypes.STRING ) );
        registerFunction( "trim", new StandardSQLFunction( "trim", StandardBasicTypes.STRING ) );
        
        /* One Parameter Numeric dialect functions */
        registerFunction( "abs", new StandardSQLFunction( "abs", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "acos", new StandardSQLFunction( "acos", StandardBasicTypes.DOUBLE ) );   /* NUMBER */
        registerFunction( "asin", new StandardSQLFunction( "asin", StandardBasicTypes.DOUBLE ) );   /* NUMBER */
        registerFunction( "atan", new StandardSQLFunction( "atan", StandardBasicTypes.DOUBLE ) );   /* NUMBER */
        registerFunction( "atan2", new StandardSQLFunction( "atan2", StandardBasicTypes.DOUBLE ) ); /* NUMBER */
        registerFunction( "avg", new StandardSQLFunction( "avg", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "bitnot", new StandardSQLFunction( "bitnot", StandardBasicTypes.LONG ) ); /* NATIVE_BIGINT */
        registerFunction( "cbrt", new StandardSQLFunction( "cbrt", StandardBasicTypes.LONG ) );     /* NUMBER */
        registerFunction( "ceil", new StandardSQLFunction( "ceil", StandardBasicTypes.INTEGER ) );  /* NUMBER */
        registerFunction( "cos", new StandardSQLFunction( "cos", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "cot", new StandardSQLFunction( "cot", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "count", new StandardSQLFunction( "count", StandardBasicTypes.LONG ) );   /* NATIVE_BIGINT */
        registerFunction( "degrees", new StandardSQLFunction( "degrees", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "exp", new StandardSQLFunction( "exp", StandardBasicTypes.DOUBLE ) );             /* NUMBER */
        registerFunction( "factorial", new StandardSQLFunction( "fatorial", StandardBasicTypes.DOUBLE ) );  /* NUMBER */
        registerFunction( "floor", new StandardSQLFunction( "floor", StandardBasicTypes.DOUBLE ) );         /* NUMBER */
        registerFunction( "ln", new StandardSQLFunction( "ln", StandardBasicTypes.DOUBLE ) );               /* NUMBER */
        registerFunction( "radians", new StandardSQLFunction( "radians", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "sign", new StandardSQLFunction( "sign", StandardBasicTypes.DOUBLE ) );           /* NUMBER */
        registerFunction( "sin", new StandardSQLFunction( "sin", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "sqrt", new StandardSQLFunction( "sqrt", StandardBasicTypes.DOUBLE ) );   /* NUMBER */
        registerFunction( "sum", new StandardSQLFunction( "sum", StandardBasicTypes.DOUBLE ) );     /* NUMBER */   
        registerFunction( "tan", new StandardSQLFunction( "tan", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "to_native_double", new StandardSQLFunction( "to_native_double", StandardBasicTypes.DOUBLE ) ); /* NATIVE_DOUBLE */
        registerFunction( "to_native_real", new StandardSQLFunction( "to_native_real", StandardBasicTypes.FLOAT ) );      /* NATIVE_REAL */
        registerFunction( "to_number", new StandardSQLFunction( "to_number", StandardBasicTypes.DOUBLE ) );               /* NUMBER */
        
        /* No Parameter Numeric dialect functions */
        registerFunction( "pi", new NoArgSQLFunction( "pi", StandardBasicTypes.DOUBLE ) ); /* NUMBER */
        
        /* Multi-Parameter Numeric dialect functions */
        registerFunction( "bitand", new StandardSQLFunction( "bitand", StandardBasicTypes.LONG ) );                      /* NATIVE_BIGINT */
        registerFunction( "bitor", new StandardSQLFunction( "bitor", StandardBasicTypes.LONG ) );                        /* NATIVE_BIGINT */
        registerFunction( "bitxor", new StandardSQLFunction( "bitxor", StandardBasicTypes.LONG ) );                      /* NATIVE_BIGINT */
        registerFunction( "log", new StandardSQLFunction( "log", StandardBasicTypes.DOUBLE ) );                          /* NUMBER */
        registerFunction( "mod", new StandardSQLFunction( "mod", StandardBasicTypes.DOUBLE ) );                          /* NUMBER */
        registerFunction( "power", new StandardSQLFunction( "power", StandardBasicTypes.DOUBLE ) );                      /* NUMBER */
        registerFunction( "random", new StandardSQLFunction( "random", StandardBasicTypes.DOUBLE ) );                    /* NUMBER */
        registerFunction( "shift_left", new StandardSQLFunction( "shift_left", StandardBasicTypes.BIG_INTEGER ) );       /* NATIVE_BIGINT */
        registerFunction( "shift_right", new StandardSQLFunction( "shift_right", StandardBasicTypes.BIG_INTEGER ) );     /* NATIVE_BIGINT */
        
        /* Date,Time */
        registerFunction( "adddate", new StandardSQLFunction( "adddate" ) );                                  /* DATE, TIMESTAMP, TIMESTAMP WITH TIME ZONE */
        registerFunction( "addtime", new StandardSQLFunction( "addtime" ) );                                  /* DATE, TIMESTAMP, TIMESTAMP WITH TIME ZONE */
        registerFunction( "add_months", new StandardSQLFunction( "add_months", StandardBasicTypes.DATE ) );   /* DATE */
        registerFunction( "dateadd", new StandardSQLFunction( "dateadd" ) );                                  /* DATE, TIMESTAMP, TIMESTAMP WITH TIME ZONE */
        registerFunction( "datediff", new StandardSQLFunction( "datediff", StandardBasicTypes.DOUBLE ) );     /* NUMBER */
        registerFunction( "date_add", new StandardSQLFunction( "date_add" ) );                                /* DATE, TIMESTAMP, TIMESTAMP WITH TIME ZONE */
        registerFunction( "date_part", new StandardSQLFunction( "date_part", StandardBasicTypes.DOUBLE ) );   /* NUMBER */
        registerFunction( "extract", new StandardSQLFunction( "extract", StandardBasicTypes.DOUBLE ) );       /* NUMBER */
        registerFunction( "last_day", new StandardSQLFunction( "last_day", StandardBasicTypes.DATE ) );       /* DATE */
        registerFunction( "next_day", new StandardSQLFunction( "next_day", StandardBasicTypes.DATE ) );       /* DATE */
        registerFunction( "sys_extract_utc", new StandardSQLFunction( "sys_extract_utc" ) );                  /* TIME, TIMESTAMP */
        registerFunction( "to_date", new StandardSQLFunction( "to_date", StandardBasicTypes.DATE ) );         /* DATE */
        registerFunction( "to_time", new StandardSQLFunction( "to_time", StandardBasicTypes.TIME ) );         /* TIME */
        registerFunction( "to_timestamp", new StandardSQLFunction( "to_timestamp", StandardBasicTypes.TIMESTAMP ) ); /* TIMESTAMP */
        registerFunction( "to_timestamp_tz", new StandardSQLFunction( "to_timestamp_tz", StandardBasicTypes.TIMESTAMP ) ); /* TIMESTAMP WITH TIME ZONE */
        registerFunction( "to_timestamp_with_time_zone", new StandardSQLFunction( "to_timestamp_with_time_zone", StandardBasicTypes.TIMESTAMP ) ); /* TIMESTAMP WITH TIME ZONE */
        registerFunction( "to_time_tz", new StandardSQLFunction( "to_time_tz", StandardBasicTypes.TIME ) );   /* TIME WITH TIME ZONE */
        registerFunction( "to_time_with_time_zone", new StandardSQLFunction( "to_time_with_time_zone", StandardBasicTypes.TIME ) ); /* TIME WITH TIME ZONE */
        
        /* No Parameter Date/Time dialect functions */
        registerFunction( "clock_date", new NoArgSQLFunction( "clock_date", StandardBasicTypes.DATE ) );                             /* DATE */                 
        registerFunction( "clock_localtime", new NoArgSQLFunction( "clock_localtime", StandardBasicTypes.TIME ) );                   /* TIME */
        registerFunction( "clock_localtimestamp", new NoArgSQLFunction( "clock_localtimestamp", StandardBasicTypes.TIMESTAMP ) );    /* TIMESTAMP */
        registerFunction( "clock_time", new NoArgSQLFunction( "clock_time", StandardBasicTypes.TIME ) );                             /* TIME */
        registerFunction( "clock_timestamp", new NoArgSQLFunction( "clock_timestamp", StandardBasicTypes.TIMESTAMP ) );              /* TIMESTAMP */
        registerFunction( "current_date", new NoArgSQLFunction( "current_date", StandardBasicTypes.DATE, false ) );                  /* DATE */
        registerFunction( "current_time", new NoArgSQLFunction( "current_time", StandardBasicTypes.TIME, false ) );                  /* TIME */
        registerFunction( "current_timestamp", new NoArgSQLFunction( "current_timestamp", StandardBasicTypes.TIMESTAMP, false ) );   /* TIMESTAMP */
        registerFunction( "localtime", new NoArgSQLFunction( "localtime", StandardBasicTypes.TIME ) );                               /* TIME */
        registerFunction( "localtimestamp", new NoArgSQLFunction( "localtimestamp", StandardBasicTypes.TIMESTAMP ) );                /* TIMESTAMP */
        registerFunction( "statement_date", new NoArgSQLFunction( "statement_date", StandardBasicTypes.DATE ) );                     /* DATE */
        registerFunction( "statement_localtime", new NoArgSQLFunction( "statement_localtime", StandardBasicTypes.TIME ) );           /* TIME */
        registerFunction( "statement_localtimestamp", new NoArgSQLFunction( "statement_localtimestamp", StandardBasicTypes.TIMESTAMP ) ); /* TIMESTAMP */
        registerFunction( "statement_time", new NoArgSQLFunction( "statement_time", StandardBasicTypes.TIME ) );                     /* TIME */
        registerFunction( "statement_timestamp", new NoArgSQLFunction( "statement_timestamp", StandardBasicTypes.TIMESTAMP ) );      /* TIMESTAMP */
        registerFunction( "transaction_date", new NoArgSQLFunction( "transaction_date", StandardBasicTypes.DATE ) );                 /* DATE */
        registerFunction( "transaction_localtime", new NoArgSQLFunction( "transaction_localtime", StandardBasicTypes.TIME ) );       /* TIME */ 
        registerFunction( "transaction_localtimestamp", new NoArgSQLFunction( "transaction_localtimestamp", StandardBasicTypes.TIMESTAMP ) ); /* TIMESTAMP */
        registerFunction( "transaction_time", new NoArgSQLFunction( "transaction_time", StandardBasicTypes.TIME ) );                 /* TIME */
        registerFunction( "transaction_timestamp", new NoArgSQLFunction( "transaction_timestamp", StandardBasicTypes.TIMESTAMP ) );  /* TIMESTAMP */
        
        registerFunction( "case2", new StandardSQLFunction( "case2" ) );
        registerFunction( "coalesce", new StandardSQLFunction( "coalesce" ) );
        registerFunction( "current_catalog", new NoArgSQLFunction( "current_catalog", StandardBasicTypes.STRING, false ) );  /* VARCHAR */ 
        registerFunction( "current_schema", new NoArgSQLFunction( "current_schema", StandardBasicTypes.STRING, false ) );    /* VARCHAR */
        registerFunction( "current_user", new NoArgSQLFunction( "current_user", StandardBasicTypes.STRING, false ) );        /* VARCHAR */
        registerFunction( "currval", new StandardSQLFunction( "currval", StandardBasicTypes.LONG ) );                        /* NATIVE_BIGINT */
        registerFunction( "decrypt_str", new StandardSQLFunction( "decrypt_str", StandardBasicTypes.STRING ) );              /* VARCHAR */
        registerFunction( "digest", new StandardSQLFunction( "digest", StandardBasicTypes.BINARY ) );                        /* VARBIANRY */  
        registerFunction( "dump", new StandardSQLFunction( "dump", StandardBasicTypes.STRING ) );                            /* VARCHAR */ 
        registerFunction( "encrypt_str", new StandardSQLFunction( "encrypt_str", StandardBasicTypes.BINARY ) );              /* VARBIANRY */
        registerFunction( "from_base64", new StandardSQLFunction( "from_base64", StandardBasicTypes.BINARY ) );              /* VARBIANRY */
        registerFunction( "greatest", new StandardSQLFunction( "greatest" ) );                                               /* Depend on data */                   
        registerFunction( "hex", new StandardSQLFunction( "hex", StandardBasicTypes.STRING ) );                              /* VARCHAR */
        registerFunction( "initcap", new StandardSQLFunction( "initcap", StandardBasicTypes.STRING ) );                      /* VARCHAR */
        registerFunction( "instr", new StandardSQLFunction( "instr", StandardBasicTypes.LONG ) );   /* NUMBER, source bigint */                      
        registerFunction( "last_identity_value", new StandardSQLFunction( "last_identity_value", StandardBasicTypes.LONG ) ); /* native_bigint*/
        registerFunction( "least", new StandardSQLFunction( "least" ) );                                                     /* Depend on data */
        registerFunction( "logon_user", new NoArgSQLFunction( "logon_user", StandardBasicTypes.STRING ) );             /* VARCHAR */
        registerFunction( "max", new StandardSQLFunction( "max" ) );                                                   /* Depend on data */
        registerFunction( "min", new StandardSQLFunction( "min" ) );                                                   /* Depend on data */
        registerFunction( "nullif", new StandardSQLFunction( "nullif" ) );                                             /* Depend on data */
        registerFunction( "nvl", new StandardSQLFunction( "nvl" ) );                                                   /* Depend on data */
        registerFunction( "nvl2", new StandardSQLFunction( "nvl2" ) );                                                 /* Depend on data */
        registerFunction( "position", new StandardSQLFunction( "position" ) );                                         /* native_bigint, null */
        registerFunction( "repeat", new StandardSQLFunction( "repeat" ) );                                             /* Depend on data */
        registerFunction( "replace", new StandardSQLFunction( "replace", StandardBasicTypes.STRING ) );                /* VARCHAR */                           
        registerFunction( "round", new StandardSQLFunction( "round" ) );                                               /* NUMBER, DATE */
        registerFunction( "rownum", new NoArgSQLFunction( "rownum", StandardBasicTypes.LONG, false ) );                /* native_bigint */
        registerFunction( "session_id", new NoArgSQLFunction( "session_id", StandardBasicTypes.LONG ) );               /* native_bigint */
        registerFunction( "session_serial", new NoArgSQLFunction( "session_serial", StandardBasicTypes.LONG ) );       /* native_bigint */
        registerFunction( "session_user", new NoArgSQLFunction( "session_user", StandardBasicTypes.STRING ) );         /* VARCHAR */
        registerFunction( "to_char", new StandardSQLFunction( "to_char", StandardBasicTypes.STRING ) );                /* VARCHAR */
        registerFunction( "to_base64", new StandardSQLFunction( "to_base64", StandardBasicTypes.STRING ) );            /* VARCHAR */
        registerFunction( "trunc", new StandardSQLFunction( "trunc" ) );                                               /* NUMBER, DATE */ 
        registerFunction( "user_id", new NoArgSQLFunction( "user_id", StandardBasicTypes.LONG ) );                     /* native_bigint */
        registerFunction( "version", new StandardSQLFunction( "version", StandardBasicTypes.STRING ) );
        registerFunction( "width_bucket", new StandardSQLFunction( "width_bucket" ) );
        
        /* Cluster functions */
        registerFunction( "local_group_id", new NoArgSQLFunction( "local_group_id", StandardBasicTypes.LONG ) );          /* native_bigint */
        registerFunction( "local_group_name", new NoArgSQLFunction( "local_group_name", StandardBasicTypes.STRING ) );
        registerFunction( "local_member_id", new NoArgSQLFunction( "local_member_id", StandardBasicTypes.LONG ) );        /* native_bigint */
        registerFunction( "local_member_name", new NoArgSQLFunction( "local_member_name", StandardBasicTypes.STRING ) );
        registerFunction( "rowid_grid_block_id", new StandardSQLFunction( "rowid_grid_block_id" ) );
        registerFunction( "rowid_grid_block_seq", new StandardSQLFunction( "rowid_grid_block_seq" ) );
        registerFunction( "rowid_member_id", new StandardSQLFunction( "rowid_member_id" ) );
        registerFunction( "rowid_object_id", new StandardSQLFunction( "rowid_object_id" ) );
        registerFunction( "rowid_page_id", new StandardSQLFunction( "rowid_page_id" ) );
        registerFunction( "rowid_row_nuumber", new StandardSQLFunction( "rowid_row_number" ) );
        registerFunction( "rowid_shard_id", new StandardSQLFunction( "rowid_shard_id" ) );
        registerFunction( "rowid_tablespace_id", new StandardSQLFunction( "rowid_tablespace_id" ) );
        registerFunction( "shard_group_id", new StandardSQLFunction( "shard_group_id" ) );
        registerFunction( "shard_id", new StandardSQLFunction( "shard_id" ) );
        registerFunction( "statement_view_scn", new NoArgSQLFunction( "statement_view_scn", StandardBasicTypes.STRING ) );
        registerFunction( "statement_view_scn_dcn", new NoArgSQLFunction( "statement_view_scn_dcn", StandardBasicTypes.DOUBLE ) ); /* NUMBER */
        registerFunction( "statement_view_scn_gcn", new NoArgSQLFunction( "statement_view_scn_gcn", StandardBasicTypes.DOUBLE ) ); /* NUMBER */
        registerFunction( "statement_view_scn_lcn", new NoArgSQLFunction( "statement_view_scn_lcn", StandardBasicTypes.DOUBLE ) ); /* NUMBER */
        }   
    
    protected void registerDefaultProperties() {
        getDefaultProperties().setProperty( Environment.STATEMENT_BATCH_SIZE, DEFAULT_BATCH_SIZE );
    }

    // database type mapping support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // hibernate type mapping support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // function support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // keyword support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // native identifier generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // IDENTITY support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
	 * Does this dialect support identity column key generation?
	 *
	 * @return True if IDENTITY columns are supported; false otherwise.
	 */
    @Override
	public boolean supportsIdentityColumns() {
		return true;
	}

    /**
	 * Does the dialect support some form of inserting and selecting
	 * the generated IDENTITY value all in the same statement.
	 *
	 * @return True if the dialect supports selecting the just
	 * generated IDENTITY in the insert statement.
	 */
    @Override
	public boolean supportsInsertSelectIdentity() {
		return true;
	}

    /**
	 * Get the select command to use to retrieve the last generated IDENTITY
	 * value for a particular table
	 *
	 * @param table The table into which the insert was done
	 * @param column The PK column.
	 * @param type The {@link java.sql.Types} type code.
	 * @return The appropriate select command
	 * @throws MappingException If IDENTITY generation is not supported.
	 */
    @Override
	public String getIdentitySelectString(String table, String column, int type) throws MappingException {
		return "select laster_identit_value() from " + table;
	}

    /**
	 * The syntax used during DDL to define a column as being an IDENTITY of
	 * a particular type.
	 *
	 * @param type The {@link java.sql.Types} type code.
	 * @return The appropriate DDL fragment.
	 * @throws MappingException If IDENTITY generation is not supported.
	 */
	public String getIdentityColumnString(int type) throws MappingException {
		return "GENERATED BY DEFAULT AS IDENTITY";
	}

    
    // SEQUENCE support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    /**
	 * Does this dialect support sequences?
	 *
	 * @return True if sequences supported; false otherwise.
	 */
    @Override
	public boolean supportsSequences() {
		return true;
	}
    
    /**
	 * Does this dialect support "pooled" sequences.  Not aware of a better
	 * name for this.  Essentially can we specify the initial and increment values?
	 *
	 * @return True if such "pooled" sequences are supported; false otherwise.
	 * @see #getCreateSequenceStrings(String, int, int)
	 * @see #getCreateSequenceString(String, int, int)
	 */
    @Override
	public boolean supportsPooledSequences() {
		return true;
	}
    
    /**
	 * Generate the appropriate select statement to to retrieve the next value
	 * of a sequence.
	 * <p/>
	 * This should be a "stand alone" select statement.
	 *
	 * @param sequenceName the name of the sequence
	 * @return String The "nextval" select string.
	 * @throws MappingException If sequences are not supported.
	 */
    @Override
	public String getSequenceNextValString(String sequenceName) throws MappingException {
        return "select " + getSelectSequenceNextValString( sequenceName ) + " from dual";
	}

	/**
	 * Generate the select expression fragment that will retrieve the next
	 * value of a sequence as part of another (typically DML) statement.
	 * <p/>
	 * This differs from {@link #getSequenceNextValString(String)} in that this
	 * should return an expression usable within another statement.
	 *
	 * @param sequenceName the name of the sequence
	 * @return The "nextval" fragment.
	 * @throws MappingException If sequences are not supported.
	 */
    @Override
	public String getSelectSequenceNextValString(String sequenceName) throws MappingException {
        return sequenceName + ".nextval"; 
	}
    
    /**
	 * Typically dialects which support sequences can create a sequence
	 * with a single command.  This is convenience form of
	 * {@link #getCreateSequenceStrings} to help facilitate that.
	 * <p/>
	 * Dialects which support sequences and can create a sequence in a
	 * single command need *only* override this method.  Dialects
	 * which support sequences but require multiple commands to create
	 * a sequence should instead override {@link #getCreateSequenceStrings}.
	 *
	 * @param sequenceName The name of the sequence
	 * @return The sequence creation command
	 * @throws MappingException If sequences are not supported.
	 */
    @Override
    protected String getCreateSequenceString(String sequenceName ) {
        return "create sequence " + sequenceName;
    }
    
    /**
	 * Overloaded form of {@link #getCreateSequenceString(String)}, additionally
	 * taking the initial value and increment size to be applied to the sequence
	 * definition.
	 * </p>
	 * The default definition is to suffix {@link #getCreateSequenceString(String)}
	 * with the string: " start with {initialValue} increment by {incrementSize}" where
	 * {initialValue} and {incrementSize} are replacement placeholders.  Generally
	 * dialects should only need to override this method if different key phrases
	 * are used to apply the allocation information.
	 *
	 * @param sequenceName The name of the sequence
	 * @param initialValue The initial value to apply to 'create sequence' statement
	 * @param incrementSize The increment value to apply to 'create sequence' statement
	 * @return The sequence creation command
	 * @throws MappingException If sequences are not supported.
	 */
    @Override
    protected String getCreateSequenceString(String sequenceName, int initialValue, int incrementSize ) {
        return "create sequence " + sequenceName + "start with " + initialValue + " increment by " + incrementSize;
    }
    
    /**
	 * Typically dialects which support sequences can drop a sequence
	 * with a single command.  This is convenience form of
	 * {@link #getDropSequenceStrings} to help facilitate that.
	 * <p/>
	 * Dialects which support sequences and can drop a sequence in a
	 * single command need *only* override this method.  Dialects
	 * which support sequences but require multiple commands to drop
	 * a sequence should instead override {@link #getDropSequenceStrings}.
	 *
	 * @param sequenceName The name of the sequence
	 * @return The sequence drop commands
	 * @throws MappingException If sequences are not supported.
	 */
    @Override
	protected String getDropSequenceString(String sequenceName) throws MappingException {
		return "drop sequence " + sequenceName;
	}

    /**
	 * Get the select command used retrieve the names of all sequences.
	 *
	 * @return The select command; or null if sequences are not supported.
	 * @see org.hibernate.tool.hbm2ddl.SchemaUpdate
	 */
    @Override
    public String getQuerySequencesString() {
        return "select sequence_name from sequences";
    }
    
    // GUID support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // limit/offset support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    /**
	 * Does this dialect support some form of limiting query results
	 * via a SQL clause?
	 *
	 * @return True if this dialect supports some form of LIMIT.
	 * @deprecated {@link #buildLimitHandler(String, RowSelection)} should be overridden instead.
	 */
    @Deprecated
    @Override
    @SuppressWarnings("deprecation")
	public boolean supportsLimit() {
		return true;
	}
    
    /**
	 * Build delegate managing LIMIT clause.
	 *
	 * @param sql SQL query.
	 * @param selection Selection criteria. {@code null} in case of unlimited number of rows.
	 * @return LIMIT clause delegate.
	 */
    @Override
    public LimitHandler buildLimitHandler(String sql, RowSelection selection) {
        return (LimitHandler)new GoldilocksLimitHandler( sql, selection );
    }
    /**
	 * Apply s limit clause to the query.
	 * <p/>
	 * Typically dialects utilize {@link #supportsVariableLimit() variable}
	 * limit clauses when they support limits.  Thus, when building the
	 * select command we do not actually need to know the limit or the offest
	 * since we will just be using placeholders.
	 * <p/>
	 * Here we do still pass along whether or not an offset was specified
	 * so that dialects not supporting offsets can generate proper exceptions.
	 * In general, dialects will override one or the other of this method and
	 * {@link #getLimitString(String, int, int)}.
	 *
	 * @param query The query to which to apply the limit.
	 * @param hasOffset Is the query requesting an offset?
	 * @return the modified SQL
	 * @deprecated {@link #buildLimitHandler(String, RowSelection)} should be overridden instead.
	 */
    @Deprecated
    @Override
    @SuppressWarnings("deprecation")
	public String getLimitString(String sql, boolean hasOffset) {
		return sql + (hasOffset ? " limit ?, ?" : " limit ?");
	}
    
    // lock acquisition support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    /**
	 * If this dialect supports specifying lock timeouts, are those timeouts
	 * rendered into the <tt>SQL</tt> string as parameters.  The implication
	 * is that Hibernate will need to bind the timeout value as a parameter
	 * in the {@link java.sql.PreparedStatement}.  If true, the param position
	 * is always handled as the last parameter; if the dialect specifies the
	 * lock timeout elsewhere in the <tt>SQL</tt> statement then the timeout
	 * value should be directly rendered into the statement and this method
	 * should return false.
	 *
	 * @return True if the lock timeout is rendered into the <tt>SQL</tt>
	 * string as a parameter; false otherwise.
	 */
    @Override
	public boolean isLockTimeoutParameterized() {
		return true;
	}

    /**
	 * Get the string to append to SELECT statements to acquire WRITE locks
	 * for this dialect.  Location of the of the returned string is treated
	 * the same as getForUpdateString.
	 *
	 * @param timeout in milliseconds, -1 for indefinite wait and 0 for no wait.
	 * @return The appropriate <tt>LOCK</tt> clause string.
	 */
    @Override
    public String getWriteLockString(int timeout) {
        if( timeout == 0 ) {
            return getForUpdateString() + " nowait";
        } else if( timeout == -1 ) {
            return getForUpdateString() + " wait";
        } else {
            return getForUpdateString() + " wait " + timeout;
        }
    }
    
    /**
	 * Get the string to append to SELECT statements to acquire WRITE locks
	 * for this dialect.  Location of the of the returned string is treated
	 * the same as getForUpdateString.
	 *
	 * @param timeout in milliseconds, -1 for indefinite wait and 0 for no wait.
	 * @return The appropriate <tt>LOCK</tt> clause string.
	 */
    @Override
    public String getReadLockString(int timeout) {
        return " for read only";
    }
    
    /**
	 * Is <tt>FOR UPDATE OF</tt> syntax supported?
	 *
	 * @return True if the database supports <tt>FOR UPDATE OF</tt> syntax;
	 * false otherwise.
	 */
    @Override
    public boolean forUpdateOfColumns() {
        return true;
    }
    
    /**
	 * Given LockOptions (lockMode, timeout), determine the appropriate for update fragment to use.
	 *
	 * @param lockOptions contains the lock mode to apply.
	 * @return The appropriate for update fragment.
	 */
    @Override
    public String getForUpdateString() {
        return " for update";
    }

    /**
	 * Get the <tt>FOR UPDATE OF column_list NOWAIT</tt> fragment appropriate
	 * for this dialect given the aliases of the columns to be write locked.
	 *
	 * @param aliases The columns to be write locked.
	 * @return The appropriate <tt>FOR UPDATE OF colunm_list NOWAIT</tt> clause string.
	 */
    @Override
    public String getForUpdateNowaitString() {
        return getForUpdateString() + " nowait";
    }
    
    
    // table support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    // temporary table support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    /**
	 * Does the dialect require that temporary table DDL statements occur in
	 * isolation from other statements?  This would be the case if the creation
	 * would cause any current transaction to get committed implicitly.
	 * <p/>
	 * JDBC defines a standard way to query for this information via the
	 * {@link java.sql.DatabaseMetaData#dataDefinitionCausesTransactionCommit()}
	 * method.  However, that does not distinguish between temporary table
	 * DDL and other forms of DDL; MySQL, for example, reports DDL causing a
	 * transaction commit via its driver, even though that is not the case for
	 * temporary table DDL.
	 * <p/>
	 * Possible return values and their meanings:<ul>
	 * <li>{@link Boolean#TRUE} - Unequivocally, perform the temporary table DDL
	 * in isolation.</li>
	 * <li>{@link Boolean#FALSE} - Unequivocally, do <b>not</b> perform the
	 * temporary table DDL in isolation.</li>
	 * <li><i>null</i> - defer to the JDBC driver response in regards to
	 * {@link java.sql.DatabaseMetaData#dataDefinitionCausesTransactionCommit()}</li>
	 * </ul>
	 *
	 * @return see the result matrix above.
	 */
    @Override
	public Boolean performTemporaryTableDDLInIsolation() {
		return Boolean.FALSE;
	}
    
    /**
	 * Do we need to drop the temporary table after use?
	 *
	 * @return True if the table should be dropped.
	 */
    @Override
	public boolean dropTemporaryTableAfterUse() {
		return false;
	}
    
    // callable statement support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
	 * Given a callable statement previously processed by {@link #registerResultSetOutParameter},
	 * extract the {@link java.sql.ResultSet} from the OUT parameter.
	 *
	 * @param statement The callable statement.
	 * @return The extracted result set.
	 * @throws SQLException Indicates problems extracting the result set.
	 */
    @Override
    public ResultSet getResultSet(CallableStatement statement) throws SQLException {
        statement.execute();
        return (ResultSet) statement.getObject( 1 );
    }
 
    /**
	 * Given a callable statement previously processed by {@link #registerResultSetOutParameter},
	 * extract the {@link java.sql.ResultSet}.
	 *
	 * @param statement The callable statement.
	 * @param position The bind position at which to register the output param.
	 *
	 * @return The extracted result set.
	 *
	 * @throws SQLException Indicates problems extracting the result set.
	 * @since 4.3
	 */
    @Override
	public ResultSet getResultSet(CallableStatement statement, int position) throws SQLException {
		statement.execute();
        return (ResultSet) statement.getObject( position );
	}


    // current timestamp support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
	 * Does this dialect support a way to retrieve the database's current
	 * timestamp value?
	 *
	 * @return True if the current timestamp can be retrieved; false otherwise.
	 */
    @Override
	public boolean supportsCurrentTimestampSelection() {
		return true;
	}
    
    /**
	 * Should the value returned by {@link #getCurrentTimestampSelectString}
	 * be treated as callable.  Typically this indicates that JDBC escape
	 * syntax is being used...
	 *
	 * @return True if the {@link #getCurrentTimestampSelectString} return
	 * is callable; false otherwise.
	 */
    @Override
    public boolean isCurrentTimestampSelectStringCallable() {
        return false;
    }
    
    /**
	 * Retrieve the command used to retrieve the current timestamp from the
	 * database.
	 *
	 * @return The command.
	 */
    @Override
	public String getCurrentTimestampSelectString() {
        return "select current_timestamp from dual";
	}
    
    // union subclass support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    /**
	 * Does this dialect support UNION ALL, which is generally a faster
	 * variant of UNION?
	 *
	 * @return True if UNION ALL is supported; false otherwise.
	 */
    @Override
	public boolean supportsUnionAll() {
		return true;
	}
    
    // miscellaneous support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    /**
	 * The fragment used to insert a row without specifying any column values.
	 * This is not possible on some databases.
	 *
	 * @return The appropriate empty values clause.
	 */
    @Override
	public String getNoColumnsInsertString() {
        // todo
		return "values ( )";
	}
    
    /**
	 * What is the maximum length Hibernate can use for generated aliases?
	 *
	 * @return The maximum length.
	 */
    @Override
	public int getMaxAliasLength() {
		return 128;
	}

    /**
	 * The SQL literal value to which this database maps boolean values.
	 *
	 * @param bool The boolean value
	 * @return The appropriate SQL literal.
	 */
    @Override
	public String toBooleanValueString(boolean bool) {
		return bool ? "TRUE" : "FALSE";
	}
    
    // identifier quoting support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    // DDL support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    /**
	 * Do we need to drop constraints before dropping tables in this dialect?
	 *
	 * @return True if constraints must be dropped prior to dropping
	 * the table; false otherwise.
	 */
    @Override
	public boolean dropConstraints() {
        // todo
		return false;
	}
    
    /**
	 * Do we need to qualify index names with the schema name?
	 *
	 * @return boolean
	 */
    @Override
	public boolean qualifyIndexName() {
		return false;
	}
    
    /**
	 * The syntax used to add a column to a table (optional).
	 *
	 * @return The "add column" fragment.
	 */
	public String getAddColumnString() {
        return " add column";
	}

	public String getDropForeignKeyString() {
        throw new UnsupportedOperationException( "Drop foreign key supported by " + getClass().getName() );
	}

	public String getTableTypeString() {
		// grrr... for differentiation of mysql storage engines
		return "";
	}
    
    /**
	 * The syntax used to add a foreign key constraint to a table.
	 *
	 * @param constraintName The FK constraint name.
	 * @param foreignKey The names of the columns comprising the FK
	 * @param referencedTable The table referenced by the FK
	 * @param primaryKey The explicit columns in the referencedTable referenced
	 * by this FK.
	 * @param referencesPrimaryKey if false, constraint should be
	 * explicit about which column names the constraint refers to
	 *
	 * @return the "add FK" fragment
	 */
    @Override
    public String getAddForeignKeyConstraintString(
            String constraintName,
            String[] foreignKey,
            String referencedTable,
            String[] primaryKey,
            boolean referencesPrimaryKey) {
        throw new UnsupportedOperationException( "Add foreign key supported by " + getClass().getName() );
    }

    /**
	 * The keyword used to specify a nullable column.
	 *
	 * @return String
	 */
    @Override
    public String getNullColumnString() {
        // todo 
		return "";
	}
    
    @Override
    public boolean supportsCommentOn() {
        return true;
    }

    @Override
    public String getTableComment(String comment) {
        // todo
		return "";
	}
    @Override
	public String getColumnComment(String comment) {
        // todo 
		return "";
	}
    
    @Override
    public boolean supportsIfExistsBeforeTableName() {
        return true;
    }

    @Override
    public String getDropTableString(String tableName) {
        final StringBuilder buffer = new StringBuilder( "drop table if exists " );
        
        buffer.append( tableName ).append( getCascadeConstraintsString() );
        
        return buffer.toString();
    }

    /**
	 * Does this dialect support column-level check constraints?
	 *
	 * @return True if column-level CHECK constraints are supported; false
	 * otherwise.
	 */
    @Override
    public boolean supportsColumnCheck() {
        return false;
    }

    
    /**
	 * Does this dialect support table-level check constraints?
	 *
	 * @return True if table-level CHECK constraints are supported; false
	 * otherwise.
	 */
    @Override
    public boolean supportsTableCheck() {
        return false;
    }

    @Override
    public boolean supportsCascadeDelete() {
        return false;
    }

    
    /**
	 * @return Returns the separator to use for defining cross joins when translating HQL queries.
	 * <p/>
	 * Typically this will be either [<tt> cross join </tt>] or [<tt>, </tt>]
	 * <p/>
	 * Note that the spaces are important!
	 *
	 */
    @Override
    public String getCrossJoinSeparator() {
        return ", ";
    }


    // Informational metadata ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
	 * Does this dialect support empty IN lists?
	 * <p/>
	 * For example, is [where XYZ in ()] a supported construct?
	 *
	 * @return True if empty in lists are supported; false otherwise.
	 * @since 3.2
	 */
    @Override
    public boolean supportsEmptyInList() {
        return false;
    }

    /**
	 * Is this dialect known to support what ANSI-SQL terms "row value
	 * constructor" syntax; sometimes called tuple syntax.
	 * <p/>
	 * Basically, does it support syntax like
	 * "... where (FIRST_NAME, LAST_NAME) = ('Steve', 'Ebersole') ...".
	 *
	 * @return True if this SQL dialect is known to support "row value
	 * constructor" syntax; false otherwise.
	 * @since 3.2
	 */
    @Override
    public boolean supportsRowValueConstructorSyntax() {
        return true;
    }

    /**
	 * If the dialect supports {@link #supportsRowValueConstructorSyntax() row values},
	 * does it offer such support in IN lists as well?
	 * <p/>
	 * For example, "... where (FIRST_NAME, LAST_NAME) IN ( (?, ?), (?, ?) ) ..."
	 *
	 * @return True if this SQL dialect is known to support "row value
	 * constructor" syntax in the IN list; false otherwise.
	 * @since 3.2
	 */
    @Override
    public boolean supportsRowValueConstructorSyntaxInInList() {
        return true;
    }

    /**
	 * Should LOBs (both BLOB and CLOB) be bound using stream operations (i.e.
	 * {@link java.sql.PreparedStatement#setBinaryStream}).
	 *
	 * @return True if BLOBs and CLOBs should be bound using stream operations.
	 * @since 3.2
	 */
    @Override
    public boolean useInputStreamToInsertBlob() {
		return false;
	}

    /**
	 * Does this dialect support definition of cascade delete constraints
	 * which can cause circular chains?
	 *
	 * @return True if circular cascade delete constraints are supported; false
	 * otherwise.
	 * @since 3.2
	 */
    @Override
    public boolean supportsCircularCascadeDeleteConstraints() {
		return false;
	}

    /**
	 * Expected LOB usage pattern is such that I can perform an insert
	 * via prepared statement with a parameter binding for a LOB value
	 * without crazy casting to JDBC driver implementation-specific classes...
	 * <p/>
	 * Part of the trickiness here is the fact that this is largely
	 * driver dependent.  For example, Oracle (which is notoriously bad with
	 * LOB support in their drivers historically) actually does a pretty good
	 * job with LOB support as of the 10.2.x versions of their drivers...
	 *
	 * @return True if normal LOB usage patterns can be used with this driver;
	 * false if driver-specific hookiness needs to be applied.
	 * @since 3.2
	 */
    @Override
    public boolean supportsExpectedLobUsagePattern() {
		return false;
	}

    /**
	 * Does the dialect support propagating changes to LOB
	 * values back to the database?  Talking about mutating the
	 * internal value of the locator as opposed to supplying a new
	 * locator instance...
	 * <p/>
	 * For BLOBs, the internal value might be changed by:
	 * {@link java.sql.Blob#setBinaryStream},
	 * {@link java.sql.Blob#setBytes(long, byte[])},
	 * {@link java.sql.Blob#setBytes(long, byte[], int, int)},
	 * or {@link java.sql.Blob#truncate(long)}.
	 * <p/>
	 * For CLOBs, the internal value might be changed by:
	 * {@link java.sql.Clob#setAsciiStream(long)},
	 * {@link java.sql.Clob#setCharacterStream(long)},
	 * {@link java.sql.Clob#setString(long, String)},
	 * {@link java.sql.Clob#setString(long, String, int, int)},
	 * or {@link java.sql.Clob#truncate(long)}.
	 * <p/>
	 * NOTE : I do not know the correct answer currently for
	 * databases which (1) are not part of the cruise control process
	 * or (2) do not {@link #supportsExpectedLobUsagePattern}.
	 *
	 * @return True if the changes are propagated back to the
	 * database; false otherwise.
	 * @since 3.2
	 */
    @Override
    public boolean supportsLobValueChangePropogation() {
		return false;
	}

    /**
	 * Is it supported to materialize a LOB locator outside the transaction in
	 * which it was created?
	 * <p/>
	 * Again, part of the trickiness here is the fact that this is largely
	 * driver dependent.
	 * <p/>
	 * NOTE: all database I have tested which {@link #supportsExpectedLobUsagePattern()}
	 * also support the ability to materialize a LOB outside the owning transaction...
	 *
	 * @return True if unbounded materialization is supported; false otherwise.
	 * @since 3.2
	 */
    @Override
    public boolean supportsUnboundedLobLocatorMaterialization() {
        return false;
    }

    /**
	 * Does the dialect support an exists statement in the select clause?
	 *
	 * @return True if exists checks are allowed in the select clause; false otherwise.
	 */
    @Override
    public boolean supportsExistsInSelect() {
        return true;
    }


    /**
     * Does this dialect support `count(distinct a,b)`?
     *
     * @return True if the database supports counting distinct tuples; false otherwise.
     */
    @Override
    public boolean supportsTupleDistinctCounts() {
        return false;
    }


    /**
	 * Apply a hint to the query.  The entire query is provided, allowing the Dialect full control over the placement
	 * and syntax of the hint.  By default, ignore the hint and simply return the query.
	 * 
	 * @param query The query to which to apply the hint.
	 * @param hints The  hints to apply
	 * @return The modified SQL
	 *
	 * @since 4.3
	 */
    @Override
	public String getQueryHintString(String query, List<String> hints) {
        final String hint = StringHelper.join( ", ", hints.iterator() );
		
		if ( StringHelper.isEmpty( hint ) ) {
			return query;
		}

		final int pos = query.indexOf( "select" );
		if ( pos > -1 ) {
			final StringBuilder buffer = new StringBuilder( query.length() + hint.length() + 8 );
			if ( pos > 0 ) {
				buffer.append( query.substring( 0, pos ) );
			}
			buffer.append( "select /*+ " ).append( hint ).append( " */" )
					.append( query.substring( pos + "select".length() ) );
			query = buffer.toString();
		}

        return query;
    }
}
