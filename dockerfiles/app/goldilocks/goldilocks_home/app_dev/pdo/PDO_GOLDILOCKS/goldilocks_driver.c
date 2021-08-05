#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "php.h"
#include "php_ini.h"
#include "ext/standard/info.h"
#include "pdo/php_pdo.h"
#include "pdo/php_pdo_driver.h"
#include "php_pdo_goldilocks.h"
#include "php_pdo_goldilocks_int.h"
#include "zend_exceptions.h"

static int pdo_goldilocks_fetch_error_func( pdo_dbh_t  * dbh,
                                            pdo_stmt_t * stmt,
                                            zval       * info TSRMLS_DC )
{
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;
    pdo_goldilocks_errinfo *einfo = &H->einfo;
    pdo_goldilocks_stmt *S = NULL;
    char *message = NULL;

    if( stmt != NULL)
    {
        S = (pdo_goldilocks_stmt*)stmt->driver_data;
        einfo = &S->einfo;
    }

    spprintf( &message,
              0,
              "%s (%s[%ld] at %s:%d)",
              einfo->last_err_msg,
              einfo->what,
              einfo->last_error,
              einfo->file,
              einfo->line );

    add_next_index_long( info, einfo->last_error );
    add_next_index_string( info, message, 0);
    add_next_index_string( info, einfo->last_state, 1 );

    return 1;
}


void pdo_goldilocks_error( pdo_dbh_t  * dbh,
                           pdo_stmt_t * stmt,
                           SQLHANDLE    statement,
                           char       * what,
                           const char * file,
                           int          line TSRMLS_DC )
{
    SQLSMALLINT	errmsgsize = 0;
    SQLHANDLE eh;
    SQLSMALLINT htype;
    SQLSMALLINT recno = 1;
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle*)dbh->driver_data;
    pdo_goldilocks_errinfo *einfo = &H->einfo;
    pdo_goldilocks_stmt *S = NULL;
    pdo_error_type *pdo_err = &dbh->error_code;

    if( stmt != NULL)
    {
        S = (pdo_goldilocks_stmt*)stmt->driver_data;

        einfo = &S->einfo;
        pdo_err = &stmt->error_code;
    }

    if( (statement == SQL_NULL_HSTMT) && (S != NULL) )
    {
        statement = S->stmt;
    }

    if( statement != NULL )
    {
        htype = SQL_HANDLE_STMT;
        eh    = statement;
    }
    else if( H->dbc != NULL )
    {
        htype = SQL_HANDLE_DBC;
        eh    = H->dbc;
    }
    else
    {
        htype = SQL_HANDLE_ENV;
        eh    = H->env;
    }

    if( !SQL_SUCCEEDED(GDLGetDiagRec( htype,
                                      eh,
                                      1,
                                      einfo->last_state,
                                      &einfo->last_error,
                                      einfo->last_err_msg,
                                      sizeof(einfo->last_err_msg),
                                      &errmsgsize )) )
    {
        errmsgsize = 0;
    }
    
    einfo->file = file;
    einfo->line = line;
    einfo->what = what;

    strcpy(*pdo_err, einfo->last_state);

    if( dbh->methods == NULL)
    {
        zend_throw_exception_ex( php_pdo_get_exception(),
                                 einfo->last_error TSRMLS_CC,
                                 "SQLSTATE[%s] %s: %d %s",
                                 *pdo_err,
                                 what,
                                 einfo->last_error,
                                 einfo->last_err_msg );
    }
}

static int goldilocks_handle_closer( pdo_dbh_t *dbh TSRMLS_DC )
{
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle*)dbh->driver_data;

    if( H->dbc != SQL_NULL_HANDLE )
    {
        GDLEndTran( SQL_HANDLE_DBC, H->dbc, SQL_ROLLBACK );
        GDLDisconnect( H->dbc );
        GDLFreeHandle( SQL_HANDLE_DBC, H->dbc );
        H->dbc = NULL;
    }
    
    GDLFreeHandle( SQL_HANDLE_ENV, H->env );
    H->env = NULL;
    pefree( H, dbh->is_persistent );
    dbh->driver_data = NULL;

    return 0;
}

static int goldilocks_handle_preparer( pdo_dbh_t  * dbh,
                                       const char * sql,
                                       long         sql_len,
                                       pdo_stmt_t * stmt,
                                       zval       * driver_options TSRMLS_DC)
{
    SQLRETURN rc;
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;
    pdo_goldilocks_stmt *S = ecalloc(1, sizeof(*S));
    enum pdo_cursor_type cursor_type = PDO_CURSOR_FWDONLY;
    int ret;
    char *nsql = NULL;
    int nsql_len = 0;

    S->H = H;

    /* before we prepare, we need to peek at the query; if it uses named parameters,
     * we want PDO to rewrite them for us */
    stmt->supports_placeholders = PDO_PLACEHOLDER_POSITIONAL;
    ret = pdo_parse_params( stmt, (char*)sql, sql_len, &nsql, &nsql_len TSRMLS_CC );
	
    if( ret == 1 )
    {
        /* query was re-written */
        sql = nsql;
    }
    else if( ret == -1 )
    {
        /* couldn't grok it */
        strcpy(dbh->error_code, stmt->error_code);
        efree(S);
        
        return 0;
    }
	
    if( !SQL_SUCCEEDED(GDLAllocHandle( SQL_HANDLE_STMT,
                                       H->dbc,
                                       &S->stmt )) )
    {
        efree(S);
        
        if( nsql != NULL )
        {
            efree(nsql);
        }
        
        pdo_goldilocks_drv_error( "GDLAllocStmt" );
        
        return 0;
    }

    cursor_type = pdo_attr_lval( driver_options,
                                 PDO_ATTR_CURSOR,
                                 PDO_CURSOR_FWDONLY TSRMLS_CC );
    
    if( cursor_type != PDO_CURSOR_FWDONLY )
    {
        if( !SQL_SUCCEEDED(GDLSetStmtAttr( S->stmt,
                                           SQL_ATTR_CURSOR_TYPE,
                                           (SQLPOINTER)SQL_CURSOR_ISO,
                                           0 )) )
        {
            pdo_goldilocks_stmt_error( "GDLSetStmtAttr: SQL_ATTR_CURSOR_TYPE" );\
            
            GDLFreeHandle( SQL_HANDLE_STMT, S->stmt );
            
            if( nsql != NULL)
            {
                efree(nsql);
            }
            
            return 0;
        }

        if( !SQL_SUCCEEDED(GDLSetStmtAttr( S->stmt,
                                           SQL_ATTR_CURSOR_SCROLLABLE,
                                           (SQLPOINTER)SQL_SCROLLABLE,
                                           0 )) )
        {
            pdo_goldilocks_stmt_error( "GDLSetStmtAttr: SQL_ATTR_CURSOR_SCROLLABLE" );\
            
            GDLFreeHandle( SQL_HANDLE_STMT, S->stmt );
            
            if( nsql != NULL)
            {
                efree(nsql);
            }
            
            return 0;
        }
    }
	
    rc = GDLPrepare( S->stmt, (char*)sql, SQL_NTS );
    
    if( nsql != NULL)
    {
        efree(nsql);
    }

    stmt->driver_data = S;
    stmt->methods = &goldilocks_stmt_methods;

    if( rc != SQL_SUCCESS )
    {
        pdo_goldilocks_stmt_error( "GDLPrepare" );
        
        if( rc != SQL_SUCCESS_WITH_INFO )
        {
            /* clone error information into the db handle */
            strcpy( H->einfo.last_err_msg, S->einfo.last_err_msg );
            H->einfo.file = S->einfo.file;
            H->einfo.line = S->einfo.line;
            H->einfo.what = S->einfo.what;
            strcpy( dbh->error_code, stmt->error_code );
        }
    }

    if( (rc != SQL_SUCCESS) && (rc != SQL_SUCCESS_WITH_INFO) )
    {
        return 0;
    }
    
    return 1;
}

static long goldilocks_handle_doer( pdo_dbh_t  * dbh,
                                    const char * sql,
                                    long         sql_len TSRMLS_DC)
{
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;
    SQLRETURN rc;
    SQLLEN row_count = -1;
    SQLHANDLE stmt;

    if( !SQL_SUCCEEDED(GDLAllocHandle( SQL_HANDLE_STMT,
                                       H->dbc,
                                       &stmt)) )
    {
        pdo_goldilocks_drv_error("GDLAllocHandle: STMT");

        return -1;
    }

    rc = GDLExecDirect( stmt, (char *)sql, sql_len );

    if( rc == SQL_NO_DATA )
    {
        /* If SQLExecDirect executes a searched update or delete statement that
         * does not affect any rows at the data source, the call to
         * SQLExecDirect returns SQL_NO_DATA. */
        row_count = 0;

        goto out;
    }

    if( !SQL_SUCCEEDED(rc) )
    {
        pdo_goldilocks_doer_error( "GDLExecDirect" );
        
        goto out;
    }

    if( !SQL_SUCCEEDED(GDLRowCount( stmt,
                                    &row_count )) )
    {
        pdo_goldilocks_doer_error( "GDLRowCount" );

        goto out;
    }

    if( row_count == -1 )
    {
        row_count = 0;
    }
    
out:
    GDLFreeHandle( SQL_HANDLE_STMT, stmt );
    
    return row_count;
}

static char *pdo_goldilocks_last_insert_id(pdo_dbh_t *dbh, const char *name, unsigned int *len TSRMLS_DC)
{
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;

    SQLHANDLE   stmt;
    char      * id = NULL;
    SQLBIGINT   lastid;
    SQLLEN      ind;

    if( !SQL_SUCCEEDED(GDLAllocHandle( SQL_HANDLE_STMT,
                                       H->dbc,
                                       &stmt)) )
    {
        pdo_goldilocks_drv_error("GDLAllocHandle: STMT");

        return NULL;
    }

    if( !SQL_SUCCEEDED(GDLBindParameter( stmt,
                                         1,
                                         SQL_PARAM_OUTPUT,
                                         SQL_C_SBIGINT,
                                         SQL_BIGINT,
                                         0,
                                         0,
                                         &lastid,
                                         0,
                                         &ind )) )
    {
        pdo_goldilocks_doer_error( "GDLBindParameter" );
        
        goto out;
    }

    if( !SQL_SUCCEEDED(GDLExecDirect( stmt,
                                      (SQLCHAR *)"SELECT LAST_IDENTITY_VALUE() INTO ? FROM dual",
                                      SQL_NTS )) )
    {
        pdo_goldilocks_doer_error( "GDLExecDirect" );
        
        goto out;
    }

    if( ind == SQL_NULL_DATA )
    {
        *len = 0;
    }
    else
    {
        id = php_pdo_int64_to_str(lastid TSRMLS_CC);
        *len = strlen(id);
    }
    
out:
    GDLFreeHandle( SQL_HANDLE_STMT, stmt );
    
    return id;
}

static int goldilocks_handle_quoter( pdo_dbh_t            * dbh,
                                     const char           * unquoted,
                                     int                    unquotedlen,
                                     char                ** quoted,
                                     int                  * quotedlen,
                                     enum pdo_param_type    param_type TSRMLS_DC)
{
    int qcount = 0;
    char const *cu, *l, *r;
    char *c;

    if( !unquotedlen )
    {
        *quotedlen = 2;
        *quoted = emalloc( *quotedlen + 1 );

        strcpy( *quoted, "''" );

        return 1;
    }

    /* count single quotes */
    for( cu = unquoted; (cu = strchr( cu,'\'' )); qcount++, cu++ ); /* empty loop */

    *quotedlen = unquotedlen + qcount + 2;
    *quoted = c = emalloc( *quotedlen + 1 );
    *c++ = '\'';
	
    /* foreach (chunk that ends in a quote) */
    for( l = unquoted; (r = strchr( l,'\'' )); l = r+1 )
    {
        strncpy( c, l, r-l+1 );
        c += (r-l+1);		
        *c++ = '\''; /* add second quote */
    }

    /* Copy remainder and add enclosing quote */	
    strncpy( c, l, *quotedlen - (c-*quoted) - 1 );
    (*quoted)[*quotedlen-1] = '\''; 
    (*quoted)[*quotedlen]   = '\0';
	
    return 1;
}

static int goldilocks_handle_begin( pdo_dbh_t *dbh TSRMLS_DC )
{
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;
    
    if( dbh->auto_commit )
    {
        /* we need to disable auto-commit now, to be able to initiate a transaction */
        if( !SQL_SUCCEEDED(GDLSetConnectAttr( H->dbc,
                                              SQL_ATTR_AUTOCOMMIT,
                                              (SQLPOINTER)SQL_AUTOCOMMIT_OFF,
                                              SQL_IS_INTEGER )) )
        {
            pdo_goldilocks_drv_error("GDLSetConnectAttr AUTOCOMMIT = OFF");

            return 0;
        }
    }
    
    return 1;
}

static int goldilocks_handle_commit( pdo_dbh_t *dbh TSRMLS_DC )
{
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;
    SQLRETURN rc;

    rc = GDLEndTran( SQL_HANDLE_DBC, H->dbc, SQL_COMMIT );

    if( rc != SQL_SUCCESS )
    {
        pdo_goldilocks_drv_error( "GDLEndTran: Commit" );

        if( rc != SQL_SUCCESS_WITH_INFO )
        {
            return 0;
        }
    }

    if( dbh->auto_commit )
    {
        /* turn auto-commit back on again */
        if( !SQL_SUCCEEDED(GDLSetConnectAttr( H->dbc,
                                              SQL_ATTR_AUTOCOMMIT,
                                              (SQLPOINTER)SQL_AUTOCOMMIT_ON,
                                              SQL_IS_INTEGER )) )
        {
            pdo_goldilocks_drv_error("GDLSetConnectAttr AUTOCOMMIT = ON");

            return 0;
        }
    }
    
    return 1;
}

static int goldilocks_handle_rollback( pdo_dbh_t *dbh TSRMLS_DC )
{
    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;
    SQLRETURN rc;

    rc = GDLEndTran( SQL_HANDLE_DBC, H->dbc, SQL_ROLLBACK );

    if( rc != SQL_SUCCESS )
    {
        pdo_goldilocks_drv_error( "GDLEndTran: Rollback" );

        if( rc != SQL_SUCCESS_WITH_INFO )
        {
            return 0;
        }
    }
    
    if( dbh->auto_commit && H->dbc)
    {
        /* turn auto-commit back on again */
        if( !SQL_SUCCEEDED(GDLSetConnectAttr( H->dbc,
                                              SQL_ATTR_AUTOCOMMIT,
                                              (SQLPOINTER)SQL_AUTOCOMMIT_ON,
                                              SQL_IS_INTEGER )) )
        {
            pdo_goldilocks_drv_error("GDLSetConnectAttr AUTOCOMMIT = ON");

            return 0;
        }
    }

    return 1;
}

static int goldilocks_handle_set_attr( pdo_dbh_t * dbh,
                                       long        attr,
                                       zval      * val TSRMLS_DC )
{
    return 0;
}

static int goldilocks_handle_get_attr( pdo_dbh_t * dbh,
                                       long        attr,
                                       zval      * val TSRMLS_DC )
{
    char buf[512];

    pdo_goldilocks_db_handle *H = (pdo_goldilocks_db_handle *)dbh->driver_data;

    switch (attr)
    {
        case PDO_ATTR_CLIENT_VERSION:
            if( H->dbc )
            {
                if( SQL_SUCCEEDED(GDLGetInfo( H->dbc,
                                              SQL_DRIVER_VER,
                                              buf,
                                              sizeof(buf),
                                              NULL )) )
                {
                    ZVAL_STRINGL(val, buf, strlen(buf), 1);
                    return 1;
                }

                pdo_goldilocks_drv_error("GDLGetInfo: SQL_DRIVER_VER");
                return 0;
            }
            break;
        case PDO_ATTR_SERVER_VERSION:
            if( H->dbc )
            {
                if( SQL_SUCCEEDED(GDLGetInfo( H->dbc,
                                              SQL_DBMS_VER,
                                              buf,
                                              sizeof(buf),
                                              NULL )) )
                {
                    ZVAL_STRINGL(val, buf, strlen(buf), 1);
                    return 1;
                }

                pdo_goldilocks_drv_error("GDLGetInfo: SQL_DBMS_VER");
                return 0;
            }
            break;
        case PDO_ATTR_PREFETCH:
        case PDO_ATTR_TIMEOUT:
        case PDO_ATTR_SERVER_INFO:
        case PDO_ATTR_CONNECTION_STATUS:
            break;
    }
    
    return 0;
}

static struct pdo_dbh_methods goldilocks_methods =
{
    goldilocks_handle_closer,
    goldilocks_handle_preparer,
    goldilocks_handle_doer,
    goldilocks_handle_quoter,
    goldilocks_handle_begin,
    goldilocks_handle_commit,
    goldilocks_handle_rollback,
    goldilocks_handle_set_attr,
    pdo_goldilocks_last_insert_id, /* last id */
    pdo_goldilocks_fetch_error_func,
    goldilocks_handle_get_attr,	/* get attr */
    NULL,	/* check_liveness */
};

static int pdo_goldilocks_handle_factory( pdo_dbh_t * dbh,
                                          zval      * driver_options TSRMLS_DC )
{
    pdo_goldilocks_db_handle *H;
    char *conn_str = NULL;

    H = pecalloc( 1, sizeof(*H), dbh->is_persistent );

    dbh->driver_data = H;
	
    GDLAllocHandle( SQL_HANDLE_ENV, SQL_NULL_HANDLE, &H->env );

    if( !SQL_SUCCEEDED(GDLSetEnvAttr( H->env,
                                      SQL_ATTR_ODBC_VERSION,
                                      (SQLPOINTER)SQL_OV_ODBC3,
                                      0 )) )
    {
        pdo_goldilocks_drv_error("GDLSetEnvAttr: ODBC3");

        goto fail;
    }

    if( !SQL_SUCCEEDED(GDLAllocHandle( SQL_HANDLE_DBC,
                                       H->env,
                                       &H->dbc )) )
    {
        pdo_goldilocks_drv_error("GDLAllocHandle (DBC)");

        goto fail;
    }

    if( !SQL_SUCCEEDED(GDLSetConnectAttr( H->dbc,
                                          SQL_ATTR_AUTOCOMMIT,
                                          (SQLPOINTER)(dbh->auto_commit ? SQL_AUTOCOMMIT_ON : SQL_AUTOCOMMIT_OFF),
                                          SQL_IS_INTEGER )) )
    {
        pdo_goldilocks_drv_error("GDLSetConnectAttr AUTOCOMMIT");

        goto fail;
    }

    if( (dbh->username && *dbh->username) &&
        (dbh->password && *dbh->password) )
    {
        spprintf( &conn_str, 0, "%s;UID=%s;PWD=%s", dbh->data_source, dbh->username, dbh->password );
    }
    else if( dbh->username && *dbh->username )
    {
        spprintf( &conn_str, 0, "%s;UID=%s", dbh->data_source, dbh->username );
    }
    else if( dbh->password && *dbh->password )
    {
        spprintf( &conn_str, 0, "%s;PWD=%s", dbh->data_source, dbh->password );
    }
    else
    {
        spprintf( &conn_str, 0, "%s", dbh->data_source );
    }

    if( !SQL_SUCCEEDED(GDLDriverConnect( H->dbc,
                                         NULL,
                                         (char*)conn_str,
                                         SQL_NTS,
                                         NULL,
                                         0,
                                         NULL,
                                         SQL_DRIVER_NOPROMPT )) )
    {
        pdo_goldilocks_drv_error("GDLDriverConnect");

        goto fail;
    }

    efree( conn_str );

    dbh->methods = &goldilocks_methods;
    dbh->alloc_own_columns = 1;
	
    return 1;

fail:

    if( conn_str != NULL )
    {
        efree( conn_str );
    }
    
    dbh->methods = &goldilocks_methods;

    goldilocks_handle_closer( dbh TSRMLS_CC );
    
    return 0;
}

pdo_driver_t pdo_goldilocks_driver =
{
    PDO_DRIVER_HEADER(goldilocks),
    pdo_goldilocks_handle_factory
};
