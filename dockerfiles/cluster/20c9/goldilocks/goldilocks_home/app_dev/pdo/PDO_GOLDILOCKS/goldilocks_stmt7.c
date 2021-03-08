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

#ifndef str_erealloc
#define str_erealloc(str, new_len)                      \
    (IS_INTERNED(str)                                   \
     ? _str_erealloc(str, new_len, INTERNED_LEN(str))   \
     : erealloc(str, new_len))

static inline char *_str_erealloc(char *str, size_t new_len, size_t old_len)
{
    char *buf = (char *) emalloc(new_len);
    memcpy(buf, str, old_len);
    return buf;
}
#endif

#define PDO_GOLDILOCKS_BUFFER_LENGTH 4000

static void free_cols( pdo_stmt_t          * stmt,
                       pdo_goldilocks_stmt * S )
{
    int i;
    
    if( S->cols )
    {
        for( i = 0; i < stmt->column_count; i++ )
        {
            if( S->cols[i].data != NULL )
            {
                efree( S->cols[i].data );
                S->cols[i].data = NULL;
            }
        }
        
        efree(S->cols);
        S->cols = NULL;
    }
}

static int goldilocks_stmt_dtor( pdo_stmt_t * stmt )
{
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;

    if( S->stmt != SQL_NULL_HANDLE )
    {
        if( stmt->executed )
        {
            GDLCloseCursor(S->stmt);
        }
        
        GDLFreeHandle( SQL_HANDLE_STMT, S->stmt );
        S->stmt = SQL_NULL_HANDLE;
    }

    free_cols( stmt, S );
    efree(S);

    return 1;
}

static int goldilocks_stmt_execute( pdo_stmt_t *stmt )
{
    SQLRETURN rc;
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;
    char *buf = NULL;
    SQLLEN row_count = -1;

    struct pdo_bound_param_data *param;
    php_stream *stm;
    int len;
    pdo_goldilocks_param *P;

    zval * parameter;

    SQLSMALLINT colcount;
    
    if( stmt->executed )
    {
        GDLCloseCursor( S->stmt );
    }
	
    rc = GDLExecute(S->stmt);	

    while( rc == SQL_NEED_DATA )
    {
        rc = GDLParamData( S->stmt, (SQLPOINTER*)&param );

        switch( rc )
        {
            case SQL_NEED_DATA:
                P = (pdo_goldilocks_param*)param->driver_data;

                if( Z_ISREF(param->parameter) )
                {
                    parameter = Z_REFVAL(param->parameter);
                }
                else
                {
                    parameter = &param->parameter;
                }
            
                if( Z_TYPE_P(parameter) != IS_RESOURCE )
                {
                    /* they passed in a string */
                    convert_to_string( parameter );
                
                    GDLPutData( S->stmt,
                                Z_STRVAL_P(parameter),
                                Z_STRLEN_P(parameter) );
                
                    continue;
                }

                /* we assume that LOBs are binary and don't need charset
                 * conversion */

                php_stream_from_zval_no_verify(stm, parameter);

                if( !stm )
                {
                    /* shouldn't happen either */
                    pdo_goldilocks_stmt_error( "input LOB is no longer a stream" );
                
                    GDLCloseCursor( S->stmt );
                
                    if( buf != NULL )
                    {
                        efree( buf );
                        buf = NULL;
                    }
                
                    return 0;
                }

                /* now suck data from the stream and stick it into the database */
                if( buf == NULL )
                {
                    buf = emalloc(8192);
                }

                do
                {
                    len = php_stream_read( stm, buf, 8192 );
                
                    if( len == 0 )
                    {
                        break;
                    }
                
                    GDLPutData( S->stmt, buf, len );
                } while( 1 );
                break;
            case SQL_SUCCESS:
                break;
            case SQL_NO_DATA:
            case SQL_SUCCESS_WITH_INFO:
                pdo_goldilocks_stmt_error( "GDLExecute" );
                break;
            default:
                if( buf != NULL )
                {
                    efree(buf);
                    buf = NULL;
                }
                
                pdo_goldilocks_stmt_error( "GDLExecute" );

                return 0;
        }
    }

    if( buf != NULL )
    {
        efree(buf);
        buf = NULL;
    }

    switch( rc )
    {
        case SQL_SUCCESS:
            break;
        case SQL_NO_DATA:
        case SQL_SUCCESS_WITH_INFO:
            pdo_goldilocks_stmt_error( "GDLExecute" );
            break;
        default:
            pdo_goldilocks_stmt_error( "GDLExecute" );
            
            return 0;
    }

    GDLRowCount( S->stmt, &row_count );
    stmt->row_count = row_count;

    if( !stmt->executed )
    {
        /* do first-time-only definition of bind/mapping stuff */

        /* how many columns do we have ? */
        GDLNumResultCols( S->stmt, &colcount );

        stmt->column_count = (int)colcount;
        S->cols = ecalloc( colcount, sizeof(pdo_goldilocks_column) );
    }

    return 1;
}

static int goldilocks_stmt_param_hook( pdo_stmt_t                  * stmt,
                                       struct pdo_bound_param_data * param,
                                       enum pdo_param_event          event_type )
{
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;
    SQLRETURN rc;
    int param_type;
    SQLSMALLINT paramtype;
    SQLSMALLINT sqltype = 0;
    SQLSMALLINT ctype = 0;
    SQLSMALLINT scale = 0;
    SQLSMALLINT nullable = 0;
    SQLULEN precision = 0;
    pdo_goldilocks_param *P;
    zval * parameter;
    
    SQLPOINTER data = NULL;
    SQLLEN     len = 0;

    php_stream *stm;
    php_stream_statbuf sb;
    int amount;
    char *ptr = NULL;
    char *end = NULL;

    zend_ulong ulen;
    char *srcbuf = NULL;
    zend_ulong srclen = 0;
	
    /* we're only interested in parameters for prepared SQL right now */
    if( param->is_param )
    {
        switch( event_type )
        {
            case PDO_PARAM_EVT_FETCH_PRE:
            case PDO_PARAM_EVT_FETCH_POST:
            case PDO_PARAM_EVT_NORMALIZE:
                /* Do nothing */
                break;
            case PDO_PARAM_EVT_FREE:
                P = param->driver_data;
                if( P )
                {
                    efree(P);
                }
                break;
            case PDO_PARAM_EVT_ALLOC:
                {
                    param_type = PDO_PARAM_TYPE(param->param_type);

                    if( Z_ISREF(param->parameter) )
                    {
                        parameter = Z_REFVAL(param->parameter);
                    }
                    else
                    {
                        parameter = &param->parameter;
                    }
                                            
                    /* figure out what we're doing */
                    switch( param_type )
                    {
                        case PDO_PARAM_LOB:
                            break;
                        case PDO_PARAM_STMT:
                            return 0;					
                        default:
                            break;
                    }

                    if( !SQL_SUCCEEDED( zllExtendedDescribeParam( S->stmt,
                                                                  (SQLUSMALLINT)param->paramno + 1,
                                                                  &paramtype,
                                                                  &sqltype,
                                                                  &precision,
                                                                  &scale,
                                                                  &nullable )) )
                    {
                        pdo_goldilocks_stmt_error( "zllExtendedDescribeParam" );

                        return 0;
                    }

                    P = emalloc( sizeof(*P) );
                    param->driver_data = P;

                    P->len = 0; /* is re-populated each EXEC_PRE */
                    P->outbuf = NULL;
                    P->paramtype = paramtype;

                    switch( param_type )
                    {
                        case PDO_PARAM_BOOL:
                            if( sizeof(long) == 4 )
                            {
                                ctype = SQL_C_SLONG;
                            }
                            else
                            {
                                ctype = SQL_C_SBIGINT;
                            }
                            sqltype = SQL_BOOLEAN;
                            data    = (SQLPOINTER)(&Z_LVAL_P(parameter));
                            break;
                        case PDO_PARAM_INT:
                            if( sizeof(long) == 4 )
                            {
                                ctype   = SQL_C_SLONG;
                                sqltype = SQL_INTEGER;
                            }
                            else
                            {
                                ctype   = SQL_C_SBIGINT;
                                sqltype = SQL_BIGINT;
                            }
                            data = (SQLPOINTER)(&Z_LVAL_P(parameter));
                            break;
                        case PDO_PARAM_STR:
                            if( (param->max_value_len >= 1) && (param->max_value_len <= 4000) )
                            {
                                sqltype   = SQL_VARCHAR;
                                precision = param->max_value_len;
                            }
                            else
                            {
                                sqltype = SQL_LONGVARCHAR;
                            }

                            if( paramtype == SQL_PARAM_INPUT )
                            {
                                ctype = SQL_C_LONGVARCHAR;
                                data  = (SQLPOINTER)&(P->strbuf);
                            }
                            else
                            {
                                ctype = SQL_C_CHAR;
                            
                                if( param->max_value_len > 0 )
                                {
                                    len = param->max_value_len + 1;
                                }
                                else
                                {
                                    len = PDO_GOLDILOCKS_BUFFER_LENGTH + 1;
                                }
                                
                                P->outbuf = emalloc( len );
                                data = (SQLPOINTER)P->outbuf;
                            }
                            break;
                        case PDO_PARAM_LOB:
                            if( (param->max_value_len >= 1) && (param->max_value_len <= 4000) )
                            {
                                sqltype   = SQL_VARBINARY;
                                precision = param->max_value_len;
                            }
                            else
                            {
                                sqltype = SQL_LONGVARBINARY;
                            }
                        
                            ctype = SQL_C_BINARY;                            

                            if( paramtype == SQL_PARAM_INPUT )
                            {
                                data = (SQLPOINTER)param;
                            }
                            else
                            {
                                if( param->max_value_len > 0 )
                                {
                                    len = param->max_value_len;
                                }
                                else
                                {
                                    len = PDO_GOLDILOCKS_BUFFER_LENGTH;
                                }
                                
                                P->outbuf = emalloc( len );
                                data = (SQLPOINTER)P->outbuf;
                            }                        
                            break;
                        case PDO_PARAM_STMT:
                            return 0;					
                        default:
                            break;
                    }

                    if( SQL_SUCCEEDED( GDLBindParameter( S->stmt,
                                                         (SQLUSMALLINT)param->paramno + 1,
                                                         paramtype,
                                                         ctype,
                                                         sqltype,
                                                         precision,
                                                         scale,
                                                         data,
                                                         len,
                                                         &P->len )) )
                    {
                        return 1;
                    }

                    pdo_goldilocks_stmt_error( "GDLBindParameter" );
                    
                    return 0;
                }

            case PDO_PARAM_EVT_EXEC_PRE:
                P = param->driver_data;
                param_type = PDO_PARAM_TYPE(param->param_type);

                if( !Z_ISREF(param->parameter) )
                {
                    parameter = &param->parameter;
                }
                else
                {
                    parameter = Z_REFVAL(param->parameter);
                }
                
                if( param_type == PDO_PARAM_LOB )
                {
                    if( Z_TYPE_P(parameter) == IS_RESOURCE)
                    {
                        php_stream_from_zval_no_verify( stm, parameter );

                        if( !stm )
                        {
                            return 0;
                        }

                        if( 0 == php_stream_stat( stm, &sb ) )
                        {
                            if( P->outbuf )
                            {
                                ptr = P->outbuf;
                                end = P->outbuf + P->len;

                                P->len = 0;
                                do
                                {
                                    amount = end - ptr;
                                    if( amount == 0 )
                                    {
                                        break;
                                    }
                                    
                                    if( amount > 8192 )
                                    {
                                        amount = 8192;
                                    }
                                    
                                    len = php_stream_read( stm, ptr, amount );
                                    
                                    if (len == 0)
                                    {
                                        break;
                                    }
                                    
                                    ptr += len;
                                    P->len += len;
                                } while( 1 );
                            }
                            else
                            {
                                P->len = SQL_LEN_DATA_AT_EXEC(sb.sb.st_size);
                            }
                        }
                        else
                        {
                            if( P->outbuf )
                            {
                                P->len = 0;
                            }
                            else
                            {
                                P->len = SQL_LEN_DATA_AT_EXEC(0);
                            }
                        }
                    }
                    else
                    {
                        P->len = Z_STRLEN_P(parameter);
                        
                        if( P->paramtype != SQL_PARAM_INPUT )
                        {
                            memcpy( P->outbuf, Z_STRVAL_P(parameter), P->len );
                        }
                    }
                }
                else if( (Z_TYPE_P(parameter) == IS_NULL) ||
                         (PDO_PARAM_TYPE(param_type) == PDO_PARAM_NULL) )
                {
                    P->len = SQL_NULL_DATA;
                }
                else
                {
                    if( param_type == PDO_PARAM_STR )
                    {
                        P->len = Z_STRLEN_P(parameter);

                        P->strbuf.len = P->len + 1;
                        P->strbuf.arr = (SQLCHAR*)Z_STRVAL_P(parameter);
                        
                        if( P->paramtype != SQL_PARAM_INPUT )
                        {
                            memcpy( P->outbuf, Z_STRVAL_P(parameter), P->len );
                        }
                    }
                }
                
                return 1;
			
            case PDO_PARAM_EVT_EXEC_POST:
                P = param->driver_data;
                param_type = PDO_PARAM_TYPE(param->param_type);

                if( P->paramtype != SQL_PARAM_INPUT )
                {
                    if( Z_ISREF(param->parameter) )
                    {
                        parameter = Z_REFVAL(param->parameter);
                    }
                    else
                    {
                        parameter = &param->parameter;
                    }
                                        
                    if( P->len == SQL_NULL_DATA )
                    {
                        zval_ptr_dtor(parameter);
                        ZVAL_NULL(parameter);
                    }
                    else
                    {
                        switch( param_type )
                        {
                            case PDO_PARAM_STR :
                                if( Z_STR_P(parameter) == NULL )
                                {
                                    Z_STR_P(parameter) = zend_string_alloc( P->len + 1, 1 );
                                }
                                else
                                {
                                    if( Z_STRLEN_P(parameter) < P->len + 1 )
                                    {
                                        Z_STR_P(parameter) = zend_string_realloc( Z_STR_P(parameter),
                                                                                  P->len + 1,
                                                                                  1 );
                                    }
                                }

                                Z_TYPE_INFO_P(parameter) = IS_STRING;
                                memcpy( Z_STRVAL_P(parameter), P->outbuf, P->len );
                                Z_STRVAL_P(parameter)[P->len] = '\0';
                                Z_STRLEN_P(parameter) = P->len;
                                break;
                            case PDO_PARAM_LOB :
                                if( Z_STR_P(parameter) == NULL )
                                {
                                    Z_STR_P(parameter) = zend_string_alloc( P->len, 1 );
                                }
                                else
                                {
                                    if( Z_STRLEN_P(parameter) < P->len )
                                    {
                                        Z_STR_P(parameter) = zend_string_realloc( Z_STR_P(parameter),
                                                                                  P->len,
                                                                                  1 );
                                    }
                                }

                                Z_TYPE_INFO_P(parameter) = IS_STRING;
                                memcpy( Z_STRVAL_P(parameter), P->outbuf, P->len );
                                Z_STRLEN_P(parameter) = P->len;
                                break;
                            default :
                                break;
                        }
                    }
                }

                return 1;
            default :
                break;
        }
    }
    
    return 1;
}

static int goldilocks_stmt_fetch( pdo_stmt_t                 * stmt,
                                  enum pdo_fetch_orientation   ori,
                                  zend_long                    offset )
{
    SQLRETURN rc;
    SQLSMALLINT pos;
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;

    switch (ori)
    {
        case PDO_FETCH_ORI_NEXT:	pos = SQL_FETCH_NEXT; break;
        case PDO_FETCH_ORI_PRIOR:	pos = SQL_FETCH_PRIOR; break;
        case PDO_FETCH_ORI_FIRST:	pos = SQL_FETCH_FIRST; break;
        case PDO_FETCH_ORI_LAST:	pos = SQL_FETCH_LAST; break;
        case PDO_FETCH_ORI_ABS:		pos = SQL_FETCH_ABSOLUTE; break;
        case PDO_FETCH_ORI_REL:		pos = SQL_FETCH_RELATIVE; break;
        default: 
            strcpy( stmt->error_code, "HY106" );
            return 0;
    }
    
    rc = GDLFetchScroll( S->stmt, pos, offset );

    if( rc == SQL_SUCCESS )
    {
        return 1;
    }
    
    if( rc == SQL_SUCCESS_WITH_INFO )
    {
        pdo_goldilocks_stmt_error("GDLFetchScroll");
        
        return 1;
    }

    if( rc == SQL_NO_DATA )
    {
        return 0;
    }

    pdo_goldilocks_stmt_error( "GDLFetchScroll" );

    return 0;
}

static int goldilocks_stmt_describe( pdo_stmt_t * stmt,
                                     int          colno )
{
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;
    struct pdo_column_data *col = &stmt->columns[colno];
    SQLSMALLINT	colnamelen;
    SQLULEN colsize;
    SQLLEN displaysize;
    SQLLEN scale;
    SQLSMALLINT ctype;

    if( !SQL_SUCCEEDED(GDLDescribeCol( S->stmt,
                                       colno + 1,
                                       S->cols[colno].colname,
                                       sizeof(S->cols[colno].colname) - 1,
                                       &colnamelen,
                                       &S->cols[colno].coltype,
                                       &colsize,
                                       NULL,
                                       NULL )) )
    {
        pdo_goldilocks_stmt_error("GDLDescribeCol");

        return 0;
    }

    if( !SQL_SUCCEEDED(GDLColAttribute( S->stmt,
                                        colno + 1,
                                        SQL_DESC_DISPLAY_SIZE,
                                        NULL,
                                        0,
                                        NULL,
                                        &displaysize )) )
    {
        pdo_goldilocks_stmt_error("GDLColAttribute : SQL_DESC_DISPLAY_SIZE");
        return 0;
    }

    switch( S->cols[colno].coltype )
    {
        case SQL_BINARY :
        case SQL_VARBINARY :
        case SQL_LONGVARBINARY :
            ctype = SQL_C_BINARY;
            col->maxlen = -1;
            col->precision = 0;
            break;
        case SQL_REAL :
        case SQL_FLOAT :
        case SQL_DOUBLE :
            ctype = SQL_C_CHAR;
            col->maxlen = displaysize;
            col->precision = colsize;
            break;
        default :
            ctype = SQL_C_CHAR;
            col->maxlen = -1;
            col->precision = 0;
            break;
    }

    col->name = zend_string_init( S->cols[colno].colname, colnamelen, 0 );

    S->cols[colno].datalen = displaysize;

    /* returning data as a string */
    col->param_type = PDO_PARAM_STR;

    if( (S->cols[colno].coltype == SQL_LONGVARBINARY) ||
        (S->cols[colno].coltype == SQL_LONGVARCHAR) )
    {
        S->cols[colno].data = emalloc( PDO_GOLDILOCKS_BUFFER_LENGTH + 1 );
    }
    else
    {
        S->cols[colno].data = emalloc( displaysize + 1 );

        if( !SQL_SUCCEEDED(GDLBindCol( S->stmt,
                                       colno + 1,
                                       ctype,
                                       S->cols[colno].data,
                                       S->cols[colno].datalen + 1,
                                       &S->cols[colno].fetched_len )) )
        {
            pdo_goldilocks_stmt_error( "GDLBindCol" );
            return 0;
        }
    }

    return 1;
}

static int goldilocks_stmt_get_col( pdo_stmt_t  * stmt,
                                    int           colno,
                                    char       ** ptr,
                                    zend_ulong  * len,
                                    int         * caller_frees )
{
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;
    pdo_goldilocks_column *C = &S->cols[colno];
    zend_ulong ulen;

    zend_ulong used = 0;
    char *buf;
    char *buf2;

    SQLRETURN rc;
    SQLSMALLINT ctype = SQL_C_CHAR;
    SQLLEN buflen = PDO_GOLDILOCKS_BUFFER_LENGTH + 1;

    switch( C->coltype )
    {
        case SQL_LONGVARBINARY :
            buflen = PDO_GOLDILOCKS_BUFFER_LENGTH;
            ctype  = SQL_C_BINARY;
        case SQL_LONGVARCHAR :
            rc = GDLGetData( S->stmt,
                             colno + 1,
                             ctype,
                             C->data,
                             buflen,
                             &C->fetched_len );

            if( rc == SQL_SUCCESS )
            {
                goto in_data;
            }

            if( rc == SQL_SUCCESS_WITH_INFO )
            {
                buf2 = emalloc(PDO_GOLDILOCKS_BUFFER_LENGTH + 1);
                buf = estrndup(C->data, PDO_GOLDILOCKS_BUFFER_LENGTH + 1);
                used = PDO_GOLDILOCKS_BUFFER_LENGTH;
			
                do
                {
                    C->fetched_len = 0;
                    rc = GDLGetData( S->stmt,
                                     colno + 1,
                                     ctype,
                                     buf2,
                                     buflen,
                                     &C->fetched_len );
				
                    if( rc == SQL_SUCCESS_WITH_INFO )
                    {
                        buf = erealloc( buf, used + PDO_GOLDILOCKS_BUFFER_LENGTH + 1 );
                        memcpy( buf + used, buf2, PDO_GOLDILOCKS_BUFFER_LENGTH );
                        used = used + PDO_GOLDILOCKS_BUFFER_LENGTH;
                    }
                    else if( rc == SQL_SUCCESS )
                    {
                        buf = erealloc( buf, used + C->fetched_len + 1 );
                        memcpy( buf + used, buf2, C->fetched_len );
                        used = used + C->fetched_len;
                    }
                    else
                    {
                        break;
                    }
                } while( 1 );
			
                efree( buf2 );
			
                buf[used] = '\0';

                *ptr = buf;
                *caller_frees = 1;
                *len = used;

                return 1;
            }

            *ptr = NULL;
            *len = 0;

            return 1;
            break;
        default :
            break;
    }

in_data:

    if( C->fetched_len == SQL_NULL_DATA )
    {
        *ptr = NULL;
        *len = 0;
    }
    else if( C->fetched_len >= 0 )
    {
        *ptr = C->data;
        *len = C->fetched_len;
    }
    else
    {
        *ptr = NULL;
        *len = 0;
    }

    return 1;
}

static int goldilocks_stmt_set_param( pdo_stmt_t * stmt,
                                      zend_long    attr,
                                      zval       * val )
{
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;

    switch( attr )
    {
        case PDO_ATTR_CURSOR_NAME:
            convert_to_string(val);

            if( SQL_SUCCEEDED(GDLSetCursorName( S->stmt,
                                                Z_STRVAL_P(val),
                                                Z_STRLEN_P(val) )) )
            {
                return 1;
            }

            pdo_goldilocks_stmt_error( "GDLSetCursorName" );
            
            return 0;
        default:
            strcpy( S->einfo.last_err_msg, "Unknown Attribute" );
            S->einfo.what = "setAttribute";
            strcpy( S->einfo.last_state, "IM001" );
            
            return -1;
    }
}

static int goldilocks_stmt_get_attr( pdo_stmt_t * stmt,
                                     zend_long    attr,
                                     zval       * val )
{
    SQLRETURN rc;
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;
    char buf[256];
    SQLSMALLINT len = 0;

    switch( attr )
    {
        case PDO_ATTR_CURSOR_NAME:
            {
                if( SQL_SUCCEEDED(GDLGetCursorName( S->stmt,
                                                    buf,
                                                    sizeof(buf),
                                                    &len )) )
                {
                    ZVAL_STRINGL(val, buf, len);
                    return 1;
                }

                pdo_goldilocks_stmt_error( "GDLGetCursorName" );
                
                return 0;
            }
        default:
            strcpy( S->einfo.last_err_msg, "Unknown Attribute" );
            S->einfo.what = "getAttribute";
            strcpy( S->einfo.last_state, "IM001" );
            
            return -1;
    }
}

static int goldilocks_stmt_get_column_meta( pdo_stmt_t * stmt,
                                            zend_long    colno,
                                            zval       * return_value )
{
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;
    zval flags;

    char decl_type[128];
    char table[128];
    SQLLEN scale;


    if( !S->cols )
    {
        return 0;
    }

    if( colno >= stmt->column_count )
    {
        pdo_goldilocks_stmt_error( "invalid column" );
        
        return 0;
    }

    if( !SQL_SUCCEEDED(GDLColAttribute( S->stmt,
                                        colno + 1,
                                        SQL_DESC_TYPE_NAME,
                                        (SQLPOINTER)decl_type,
                                        sizeof(decl_type),
                                        NULL,
                                        NULL )) )
    {
        pdo_goldilocks_stmt_error( "GDLColAttribute : SQL_DESC_LOCAL_TYPE_NAME" );
        
        return 0;
    }

    if( !SQL_SUCCEEDED(GDLColAttribute( S->stmt,
                                        colno + 1,
                                        SQL_DESC_TABLE_NAME,
                                        (SQLPOINTER)table,
                                        sizeof(table),
                                        NULL,
                                        NULL )) )
    {
        pdo_goldilocks_stmt_error( "GDLColAttribute : SQL_DESC_TABLE_NAME" );
        
        return 0;
    }

    if( !SQL_SUCCEEDED(GDLColAttribute( S->stmt,
                                        colno + 1,
                                        SQL_DESC_SCALE,
                                        NULL,
                                        0,
                                        NULL,
                                        &scale )) )
    {
        pdo_goldilocks_stmt_error( "GDLColAttribute : SQL_DESC_SCALE" );
        
        return 0;
    }
    
    array_init(return_value);
    array_init(&flags);

    switch( S->cols[colno].coltype )
    {
        case SQL_BOOLEAN :
            add_assoc_string( return_value, "native_type", "boolean" );
            break;
        case SQL_REAL :
        case SQL_DOUBLE :
        case SQL_FLOAT :
            add_assoc_string( return_value, "native_type", "double" );
            break;
        case SQL_NUMERIC :
        case SQL_DECIMAL :
            if( scale == 0 )
            {
                add_assoc_string( return_value, "native_type", "integer" );
            }
            else
            {
                add_assoc_string( return_value, "native_type", "double" );
            }
            break;
        case SQL_BIT :
        case SQL_TINYINT :
        case SQL_SMALLINT :
        case SQL_INTEGER :
            add_assoc_string( return_value, "native_type", "integer" );
            break;
        default :
            add_assoc_string( return_value, "native_type", "string" );
            break;
    }

    add_assoc_string( return_value, "goldilocks:decl_type", decl_type );
    add_assoc_zval( return_value, "flags", &flags );
    add_assoc_string( return_value, "table", table );
    
    return 1;
}

static int goldilocks_stmt_next_rowset( pdo_stmt_t *stmt )
{
    return 0;
}

static int pdo_goldilocks_stmt_cursor_closer( pdo_stmt_t *stmt )
{
    pdo_goldilocks_stmt *S = (pdo_goldilocks_stmt*)stmt->driver_data;

    if( S->stmt != SQL_NULL_HANDLE )
    {
        if( stmt->executed )
        {
            GDLCloseCursor(S->stmt);
        }
    }

    return 1;
}

struct pdo_stmt_methods goldilocks_stmt_methods =
{
    goldilocks_stmt_dtor,
    goldilocks_stmt_execute,
    goldilocks_stmt_fetch,
    goldilocks_stmt_describe,
    goldilocks_stmt_get_col,
    goldilocks_stmt_param_hook,
    goldilocks_stmt_set_param,
    goldilocks_stmt_get_attr,
    goldilocks_stmt_get_column_meta,
    goldilocks_stmt_next_rowset,
    pdo_goldilocks_stmt_cursor_closer
};
