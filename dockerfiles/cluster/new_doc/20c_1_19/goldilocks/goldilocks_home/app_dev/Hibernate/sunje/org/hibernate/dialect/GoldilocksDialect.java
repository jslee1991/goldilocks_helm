package org.hibernate.dialect;

import org.hibernate.cfg.Environment;
import org.hibernate.dialect.Dialect;
import org.hibernate.dialect.function.NoArgSQLFunction;
import org.hibernate.dialect.function.StandardSQLFunction;
import org.hibernate.dialect.function.VarArgsSQLFunction;
import org.hibernate.dialect.pagination.AbstractLimitHandler;
import org.hibernate.dialect.pagination.LimitHandler;
import org.hibernate.dialect.pagination.LimitHelper;
import org.hibernate.engine.spi.RowSelection;
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


/**
 * An SQL dialect for SUNJESOFT Goldilocks (3.1.x and later).
 * 
 * @author lkh
 * 
 * @see
 * << Modification Information >>
 * 
 */
public class GoldilocksDialect extends Dialect {
    private static final Pattern SQL_STATEMENT_TYPE_PATTERN = Pattern.compile("^\\s*(select|insert|update|delete)\\s+.*?");
    
    private static final LimitHandler LIMIT_HANDLER = new AbstractLimitHandler() {
        @Override
        public boolean supportsLimit() {
            return true;
        }
        
        @Override
        public boolean useMaxForLimit() {
            return false;
        }
        
        @Override
        public String processSql(String aSql, RowSelection aSelection){
            if( LimitHelper.useLimit(  this, aSelection ) == true ) {
                boolean sHasOffset = LimitHelper.hasFirstRow( aSelection );
                return aSql + ( (sHasOffset == true) ? " limit ?,?" : " limit ?" );
            }
            else {
                return aSql;
            }
        }
    };
    
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

    @Override
    public LimitHandler getLimitHandler() {
        return LIMIT_HANDLER;
    }
    
    /**
     * Override DBMS supports functions 
     */
    @Override
    public boolean supportsBindAsCallableArgument() {
        return true;
    }
    
    @Override
    public boolean supportsCascadeDelete() {
        return false;
    }
    
    @Override
    public boolean supportsCaseInsensitiveLike() {
        return false;
    }
    
    @Override
    public boolean supportsCircularCascadeDeleteConstraints() {
        return false;
    }
    
    @Override
    public boolean supportsColumnCheck() {
        return false;
    }
    
    @Override
    public boolean supportsCommentOn() {
        return true;
    }
    
    @Override
    public boolean supportsCurrentTimestampSelection() {
        return true;
    }
    
    @Override
    public boolean supportsEmptyInList() {
        return false;
    }
    
    @Override
    public boolean supportsExistsInSelect() {
        return true;
    }
    
    @Override
    public boolean supportsExpectedLobUsagePattern() {
        return false;
    }
    
    @Override
    public boolean supportsIfExistsAfterConstraintName() {
        return false;
    }
    
    @Override
    public boolean supportsIfExistsAfterTableName() {
        return false;
    }
    
    @Override
    public boolean supportsIfExistsBeforeConstraintName() {
        return false;
    }
    
    @Override
    public boolean supportsIfExistsBeforeTableName() {
        return true;
    }
    
    @Override
    public boolean supportsLimit() {
        return true;
    }
    
    @Override
    public boolean supportsLimitOffset() {
        return true;
    }

    @Override
    @SuppressWarnings("deprecation")
	public String getLimitString(String sql, boolean hasOffset) {
		return sql + (hasOffset ? " limit ?, ?" : " limit ?");
	}

    @Override
    public boolean supportsLobValueChangePropogation() {
        return false;
    }
    
    @Override
    public boolean supportsLockTimeouts() {
        return true;
    }
    
    @Override
    public boolean supportsNamedParameters(DatabaseMetaData databaseMetaData) throws SQLException {
        return databaseMetaData.supportsNamedParameters();  
    }
    
    @Override
    public boolean supportsNationalizedTypes() {
        return true;
    }
    
    @Override
    public boolean supportsNonQueryWithCTE() {
        return false;
    }
    
    @Override
    public boolean supportsNotNullUnique() {
        return true;
    }
    
    @Override
    public boolean supportsOuterJoinForUpdate() {
        return true;
    }
    
    @Override
    public boolean supportsParametersInInsertSelect() {
        return true;
    }
    
    @Override
    public boolean supportsPartitionBy() {
        return false;
    }
    
    @Override
    public boolean supportsPooledSequences() {
        return true;
    }
    
    @Override
    public boolean supportsResultSetPositionQueryMethodsOnForwardOnlyCursor() {
        return true;
    }
    
    @Override
    public boolean supportsRowValueConstructorSyntax() {
        return true;
    }
    
    @Override
    public boolean supportsRowValueConstructorSyntaxInInList() {
        return true;
    }
    
    @Override
    public boolean supportsSequences() {
        return true;
    }
    
    @Override
    public boolean supportsSkipLocked() {
        return false;
    }
    
    @Override
    public boolean supportsSubqueryOnMutatingTable() {
        return true;
    }
    
    @Override
    public boolean supportsSubselectAsInPredicateLHS() {
        return true;
    }
    
    @Override
    public boolean supportsTableCheck() {
        return false;
    }
    
    @Override
    public boolean supportsTupleCounts() {
        return false;
    }
    
    @Override
    public boolean supportsTupleDistinctCounts() {
        return false;
    }
    
    @Override
    public boolean supportsTuplesInSubqueries() {
        return true;
    }
    
    @Override
    public boolean supportsUnboundedLobLocatorMaterialization() {
        return false;
    }
    
    @Override
    public boolean supportsUnionAll() {
        return true;
    }
    
    @Override
    public boolean supportsUnique() {
        return true;
    }
    
    @Override
    public boolean supportsUniqueConstraintInCreateAlterTable() {
        return true;
    }
    
    @Override
    public boolean supportsValuesList() {
        return true;
    }
    
    @Override
    public boolean supportsVariableLimit() {
        return true;
    }
    
    @Override
    public boolean areStringComparisonsCaseInsensitive() {
        return false;
    }
    
    @Override
    public boolean bindLimitParametersFirst() {
        return false;
    }
    
    @Override
    public boolean bindLimitParametersInReverseOrder() {
        return false;
    }
    
    @Override
    public boolean canCreateCatalog() {
        return false;
    }
    
    @Override
    public boolean canCreateSchema() {
        return true;
    }
    
    @Override
    public boolean doesReadCommittedCauseWritersToBlockReaders() {
        return false;
    }
    
    @Override
    public boolean doesRepeatableReadCauseReadersToBlockWriters() {
        return false;
    }
    
    @Override
    public boolean dropConstraints() {
        return false; 
    }
    
    @Override
    public boolean forceLimitUsage() {
        return false;
    }
    
    @Override
    public boolean forceLobAsLastValue() {
        return false;
    }
    
    @Override
    public boolean forUpdateOfColumns() {
        return true;
    }
    
    @Override
    public boolean hasAlterTable() {
        return true;
    }
    
    @Override
    public boolean hasSelfReferentialForeignKeyBug() {
        return false;
    }

    @Override
    public boolean isCurrentTimestampSelectStringCallable() {
        return false;
    }
    
    @Override
    public boolean isJdbcLogWarningsEnabledByDefault() {
        return false;
    }
    
    @Override
    public boolean isLockTimeoutParameterized() {
        return true;
    }

    @Override
    public boolean qualifyIndexName() {
        return false;
    }
    
    @Override
    public boolean replaceResultVariableInOrderByClauseWithPosition() {
        return false;
    }
    
    @Override
    public boolean requiresCastingOfParametersInSelectClause() {
        return false;
    }
    
    @Override
    public boolean requiresParensForTupleDistinctCounts() {
        return false;
    }
    
    @Override
    public boolean useFollowOnLocking() {
        return false;
    }
    
    @Override
    public boolean useInputStreamToInsertBlob() {
        return false;
    }
    
    @Override
    public boolean useMaxForLimit() {
        return false;
    }
    
    /**
     * Override get**String functions 
     */
    @Override
    public String getSequenceNextValString(String sequenceName) {
        return "select " + getSelectSequenceNextValString( sequenceName ) + ".nextval" + "from dual";
    }
    
    @Override
    public String getSelectSequenceNextValString(String sequenceName) {
        return sequenceName + ".nextval"; 
    }
    
    @Override
    public String[] getCreateSequenceStrings(String sequenceName) {
        return new String[] { getCreateSequenceString( sequenceName ) };
    }
    
    @Override
    protected String getCreateSequenceString(String sequenceName ) {
        return "create sequence " + sequenceName;
    }
 
    @Override
    public String[] getCreateSequenceStrings(String sequenceName, int initialValue, int incrementSize ) {
        return new String[] { getCreateSequenceString( sequenceName, initialValue, incrementSize ) };
    }
    
    @Override
    protected String getCreateSequenceString(String sequenceName, int initialValue, int incrementSize ) {
        return "create sequence " + sequenceName + "start with " + initialValue + " increment by " + incrementSize;
    }
    
    @Override
    public String[] getDropSequenceStrings( String sequenceName ) {
        return new String[]{ getDropSequenceString( sequenceName ) };
    }
    
    @Override
    public String getDropSequenceString(String sequenceName) {
        return "drop sequence " + sequenceName;
    }
 
    @Override
    public String getQuerySequencesString() {
        return "select sequence_name from sequences";
    }
    
    @Override
    public String getDropTableString(String tableName) {
        final StringBuilder buffer = new StringBuilder( "drop table " );
        if( supportsIfExistsBeforeTableName() ) {
            buffer.append( "if exists " );
        }
        buffer.append( tableName ).append( getCascadeConstraintsString() );
        if( supportsIfExistsAfterTableName() ) {
            buffer.append( " if exists" );
        }
        
        return buffer.toString();
    }
    
    @Override
    public String getForUpdateString() {
        return " for update";
    }

    @Override
    public String getForUpdateNowaitString() {
        return getForUpdateString() + " nowait";
    }
    
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
    
    @Override
    public String getReadLockString(int timeout) {
        return " for read only";
    }
    
    @Override
    public String getAlterTableString(String tableName) {
        return "alter table " + tableName;
    }
    
    @Override
    public ResultSet getResultSet(CallableStatement statement) throws SQLException {
        statement.execute();
        return (ResultSet) statement.getObject( 1 );
    }
    
    @Override
    public String getCurrentTimestampSelectString() {
        return "select current_timestamp from dual";
    }
    
    @Override
    public String getCurrentTimestampSQLFunctionName() {
        return "current_timestamp";
    }
    
    @Override
    public String getSelectClauseNullString(int sqlType) {
        return "null";
    }
    
    @Override
    public String getCurrentSchemaCommand() {
        return "select current_schema from dual";
    }

    @Override
    public String getAddColumnString() {
        return " add column";
    }
    
    @Override
    public String getDropForeignKeyString() {
        throw new UnsupportedOperationException( "Drop foreign key supported by " + getClass().getName() );
    }
    
    @Override
    public String getAddForeignKeyConstraintString(String constraintName,
                                                   String foreignKeyDefinition) {
        throw new UnsupportedOperationException( "Add foreign key supported by " + getClass().getName() );
    }
    
    @Override
    public String getAddForeignKeyConstraintString(
            String constraintName,
            String[] foreignKey,
            String referencedTable,
            String[] primaryKey,
            boolean referencesPrimaryKey) {
        throw new UnsupportedOperationException( "Add foreign key supported by " + getClass().getName() );
    }
    
    @Override
    public String getAddPrimaryKeyConstraintString(String constraintName) {
        return " add constraint " + constraintName + " primary key ";
    }   
    
    @Override
    public String getAddUniqueConstraintString(String constraintName) {
        return " add constraint " + constraintName + " unique ";
    }
    
    @Override
    public String getCrossJoinSeparator() {
        return ", ";
    }
    
    @Override
    public String getNotExpression(String expression) {
        return "not " + expression;    
    }
    
    @Override
    public String getQueryHintString(String sql, String hints) {
         String SQLStatementType = getSQLStatementType(sql);
         
         final int pos = sql.indexOf( SQLStatementType );
         if( pos > -1 ) {
             final StringBuilder buffer = new StringBuilder( sql.length() + hints.length() + 10 );
             if( pos > 0 ){
                 buffer.append(  sql.substring( 0, pos ) );
             }
             
             buffer
             .append( SQLStatementType )
             .append( " /*+ " ).append( hints ).append( " */ ")
             .append( sql.substring( pos + SQLStatementType.length() ) );
         }
         
        return sql;
    }
    
    protected String getSQLStatementType(String sql) {
        Matcher matcher = SQL_STATEMENT_TYPE_PATTERN.matcher( sql );
        
        if(matcher.matches() && matcher.groupCount() == 1) {
            return matcher.group(1);
        }
        
        throw new IllegalArgumentException( "Can't determine SQL statement: " + sql );
    }
    
    @Override
    public CaseFragment createCaseFragment() {
        return new ANSICaseFragment();
    }
    
    @Override
    public JoinFragment createOuterJoinFragment() {
        return new ANSIJoinFragment();
    }
    
}
