#include <goldilocks.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void display_param_status();
void display_data();
void check_error( SQLSMALLINT, SQLHANDLE, SQLRETURN, int, char *);
void print_error( SQLSMALLINT, SQLHANDLE, SQLRETURN, int, char *);
void cleanup();

#define CHECK_HANDLE( aHandleType, aHandle, rc )                        \
    if( rc != SQL_SUCCESS )                                             \
    {                                                                   \
        check_error( aHandleType, aHandle , rc , __LINE__, __FILE__ );  \
        cleanup();                                                      \
        return -1;                                                      \
    }

#define ROW_ARRAY_SIZE 10

typedef struct
{
    SQLCHAR    mCol1[11];
    SQLLEN     mColInd1;
    SQLINTEGER mCol2;
    SQLLEN     mColInd2;
} TROW_WISE;

SQLUSMALLINT gParamStatusArray[ROW_ARRAY_SIZE];
SQLULEN      gParamsProcessed;

SQLHENV  gEnv  = SQL_NULL_HENV;
SQLHDBC  gDbc  = SQL_NULL_HDBC;
SQLHSTMT gStmt = SQL_NULL_HSTMT;

int main( int argc, char ** argv )
{
    SQLRETURN    rc;
    TROW_WISE    Row[ROW_ARRAY_SIZE];
    SQLUSMALLINT ParamOperationArray[ROW_ARRAY_SIZE];
    int          i;
    
    rc = SQLAllocHandle( SQL_HANDLE_ENV, NULL, &gEnv );
    CHECK_HANDLE( SQL_HANDLE_ENV, gEnv, rc );
    
    rc = SQLSetEnvAttr( gEnv,
                        SQL_ATTR_ODBC_VERSION,
                        (SQLPOINTER)SQL_OV_ODBC3,
                        0 );
    CHECK_HANDLE( SQL_HANDLE_ENV, gEnv, rc );
    
    rc = SQLAllocHandle( SQL_HANDLE_DBC, gEnv, &gDbc );
    CHECK_HANDLE( SQL_HANDLE_ENV, gEnv, rc );
    
    rc = SQLConnect( gDbc,
                     (SQLCHAR*)"GOLDILOCKS", SQL_NTS,
                     (SQLCHAR*)"TEST",  SQL_NTS,
                     (SQLCHAR*)"test",  SQL_NTS );
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLAllocHandle( SQL_HANDLE_STMT, gDbc, &gStmt );
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"DROP TABLE IF EXISTS TROW_WISE",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"CREATE TABLE TROW_WISE ( C1 VARCHAR(10), C2 INTEGER PRIMARY KEY )",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );


    /*
     * INSERT
     */

    rc = SQLSetStmtAttr( gStmt, SQL_ATTR_PARAM_BIND_TYPE, (SQLPOINTER)sizeof( TROW_WISE ), 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLSetStmtAttr( gStmt, SQL_ATTR_PARAMSET_SIZE, (SQLPOINTER)ROW_ARRAY_SIZE, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLSetStmtAttr( gStmt, SQL_ATTR_PARAM_OPERATION_PTR, ParamOperationArray, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLSetStmtAttr( gStmt, SQL_ATTR_PARAM_STATUS_PTR, gParamStatusArray, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLSetStmtAttr( gStmt, SQL_ATTR_PARAMS_PROCESSED_PTR, (SQLPOINTER)&gParamsProcessed, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );


    rc = SQLBindParameter( gStmt,
                           1,
                           SQL_PARAM_INPUT,
                           SQL_C_CHAR,
                           SQL_VARCHAR,
                           10,
                           0,
                           Row[0].mCol1,
                           sizeof( Row[0].mCol1 ),
                           &Row[0].mColInd1 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
                             
    rc = SQLBindParameter( gStmt,
                           2,
                           SQL_PARAM_INPUT,
                           SQL_C_SLONG,
                           SQL_INTEGER,
                           0,
                           0,
                           &Row[0].mCol2,
                           0,
                           &Row[0].mColInd2 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLPrepare( gStmt, (SQLCHAR*)"INSERT INTO TROW_WISE VALUES ( ?, ? )", SQL_NTS );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    for( i = 0; i < ROW_ARRAY_SIZE; i++ )
    {
        ParamOperationArray[i] = SQL_PARAM_PROCEED;
        
        memset( Row[i].mCol1, 'A' + i, 10 );
        
        Row[i].mCol1[10] = 0;
        Row[i].mColInd1  = SQL_NTS;
        
        Row[i].mCol2    = i;
        Row[i].mColInd2 = 0;
    }

    rc = SQLExecute( gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    display_param_status();

    for( i = 0; i < ROW_ARRAY_SIZE; i++ )
    {
        ParamOperationArray[i] = SQL_PARAM_PROCEED;
        
        memset( Row[i].mCol1, 'A' + ROW_ARRAY_SIZE + i, 10 );
        
        Row[i].mCol1[10] = 0;
        Row[i].mColInd1  = SQL_NTS;
        
        Row[i].mCol2    = ROW_ARRAY_SIZE + i;
        Row[i].mColInd2 = 0;
    }

    for( i = 4; i < ROW_ARRAY_SIZE; i++ )
    {
        ParamOperationArray[i] = SQL_PARAM_IGNORE;
    }

    rc = SQLExecute( gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    display_param_status();

    rc = SQLFreeHandle( SQL_HANDLE_STMT, gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    gStmt = SQL_NULL_HSTMT;

    /*
     * SELECT
     */

    rc = SQLAllocHandle( SQL_HANDLE_STMT, gDbc, &gStmt );
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"SELECT * FROM TROW_WISE",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
    
    printf( "\n-- fetch data --\n" );
    display_data();

    rc = SQLCloseCursor( gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
    
    rc = SQLFreeHandle( SQL_HANDLE_STMT, gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
    
    printf( "rollback\n" );
    rc = SQLEndTran( SQL_HANDLE_DBC, gDbc, SQL_ROLLBACK );
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    printf( "disconnecting\n" );
    rc = SQLDisconnect(gDbc);
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLFreeHandle( SQL_HANDLE_DBC, gDbc );
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLFreeHandle( SQL_HANDLE_ENV, gEnv );
    CHECK_HANDLE( SQL_HANDLE_ENV, gEnv, rc );
    
    return 0;   
}

void display_param_status()
{
    int i;
    
    printf( "\nParameter Set  Status\n");
    printf( "-------------  -------------\n");
    
    for( i = 0; i < gParamsProcessed; i++ )
    {
        switch( gParamStatusArray[i] )
        {
            case SQL_PARAM_SUCCESS :
                printf( "%13d  SUCCESS\n", i );
                break;
            case SQL_PARAM_SUCCESS_WITH_INFO :
                printf( "%13d  SUCCESS WITH INFO\n", i );
                break;
            case SQL_PARAM_ERROR :
                printf( "%13d  ERROR\n", i );
                break;
            case SQL_PARAM_UNUSED :
                printf( "%13d  NOT PROCESSED\n", i );
                break;
            case SQL_PARAM_DIAG_UNAVAILABLE :
                printf( "%13d  UNKOWN\n", i );
                break;
        }
    }
}

void display_data()
{
    SQLRETURN  rc;
    SQLCHAR    Col1[11];
    SQLINTEGER Col2;
    SQLLEN     Ind;

    printf( "C1          C2\n" );
    printf( "---------- ---\n" );

    while( 1 )
    {
        rc = SQLFetch( gStmt );

        if( rc == SQL_NO_DATA )
        {
            break;
        }
        
        switch( rc )
        {
            case SQL_SUCCESS_WITH_INFO :
                check_error( SQL_HANDLE_STMT, gStmt, rc, __LINE__, __FILE__ );
            case SQL_SUCCESS :
                rc = SQLGetData( gStmt, 1, SQL_C_CHAR, Col1, sizeof( Col1 ), &Ind );

                if( rc != SQL_SUCCESS )
                {
                    check_error( SQL_HANDLE_STMT, gStmt, rc, __LINE__, __FILE__ );
                    break;
                }
                
                if( Ind == SQL_NULL_DATA )
                {
                    printf( "(null) " );
                }
                else
                {
                    printf( "%-11s", Col1 );
                }

                rc = SQLGetData( gStmt, 2, SQL_C_SLONG, &Col2, 0, &Ind );

                if( rc != SQL_SUCCESS )
                {
                    check_error( SQL_HANDLE_STMT, gStmt, rc, __LINE__, __FILE__ );
                    break;
                }
                
                if( Ind == SQL_NULL_DATA )
                {
                    printf( "(null)\n" );
                }
                else
                {
                    printf( "%3d\n", Col2 );
                }
                break;
            default :
                check_error( SQL_HANDLE_STMT, gStmt, rc, __LINE__, __FILE__ );
                break;
        }
        
        if( rc == SQL_ERROR )
        {
            break;
        }
    }
}

void check_error( SQLSMALLINT   aHandleType,
                  SQLHANDLE     aHandle,
                  SQLRETURN     aRet,
                  int           aLine,
                  char        * aFile )
{
    switch( aRet )
    {
        case SQL_SUCCESS :
            break;
        case SQL_INVALID_HANDLE :
            printf( "check_error> SQL_INVALID HANDLE \n" );
            break;
        case SQL_ERROR :
            printf( "check_error> SQL_ERROR\n" );
            break;
        case SQL_SUCCESS_WITH_INFO :
            printf( "check_error> SQL_SUCCESS_WITH_INFO\n" );
            break;
        case SQL_NO_DATA :
            printf( "check_error> SQL_NO_DATA\n" );
            break;                                                         
        default:
            printf( "check_error> Received rc = %d\n", aRet );
            break;                                                         
    }
    
    print_error( aHandleType, aHandle, aRet, aLine, aFile );
}

void print_error( SQLSMALLINT   aHandleType,
                  SQLHANDLE     aHandle,
                  SQLRETURN     aRet,
                  int           aLine,
                  char        * aFile) 
{
    SQLCHAR     sMessage[SQL_MAX_MESSAGE_LENGTH + 1];
    SQLCHAR     sSqlState[SQL_SQLSTATE_SIZE + 1];
    SQLINTEGER  sNativeError;
    SQLSMALLINT sLength;
    SQLSMALLINT i = 1;
    
    printf( "return code = %d reported from file: %s, line: %d\n",
            aRet, aFile, aLine );
    
    while( SQL_SUCCEEDED(SQLGetDiagRec( aHandleType,
                                        aHandle,
                                        i,
                                        sSqlState,
                                        &sNativeError,
                                        sMessage,
                                        SQL_MAX_MESSAGE_LENGTH,
                                        &sLength )) ) 
    {                          
        printf( "SQLSTATE: %s\n", sSqlState );
        printf( "Native Error Code: %d\n", sNativeError );
        printf( "Message: %s \n\n", sMessage );

        i++;                                                           
    }
}

void cleanup()
{
    if( gStmt != SQL_NULL_HSTMT )
    {
        (void)SQLFreeHandle( SQL_HANDLE_STMT, gStmt );
        gStmt = SQL_NULL_HSTMT;
    }

    if( gDbc != SQL_NULL_HSTMT )
    {
        (void)SQLEndTran( SQL_HANDLE_DBC, gDbc, SQL_ROLLBACK);
        (void)SQLDisconnect( gDbc );        
        (void)SQLFreeHandle( SQL_HANDLE_DBC, gDbc);

        gDbc = NULL;
    }

    if( gEnv != SQL_NULL_HENV )
    {
        (void)SQLFreeHandle( SQL_HANDLE_ENV, gEnv );
        gEnv = SQL_NULL_HSTMT;
    }
}
