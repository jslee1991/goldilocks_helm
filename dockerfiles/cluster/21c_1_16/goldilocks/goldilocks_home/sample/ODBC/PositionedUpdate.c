#include <goldilocks.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void display_data( SQLSMALLINT, SQLLEN );
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

SQLCHAR      gCol1[ROW_ARRAY_SIZE][11];
SQLINTEGER   gCol2[ROW_ARRAY_SIZE];
SQLLEN       gColInd1[ROW_ARRAY_SIZE];
SQLLEN       gColInd2[ROW_ARRAY_SIZE];
SQLULEN      gNumRowsFetched;

SQLHENV  gEnv        = SQL_NULL_HENV;
SQLHDBC  gDbc        = SQL_NULL_HDBC;
SQLHSTMT gStmtSelUpd = SQL_NULL_HSTMT;
SQLHSTMT gStmt       = SQL_NULL_HSTMT;

int main( int argc, char ** argv )
{
    SQLRETURN rc;
    
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
    
    rc = SQLSetConnectAttr( gDbc,
                            SQL_AUTOCOMMIT,
                            (SQLPOINTER)SQL_AUTOCOMMIT_OFF,
                            0 );    
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLAllocHandle( SQL_HANDLE_STMT, gDbc, &gStmt );
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLAllocHandle( SQL_HANDLE_STMT, gDbc, &gStmtSelUpd );
    CHECK_HANDLE( SQL_HANDLE_DBC, gDbc, rc );
    
    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"DROP TABLE IF EXISTS TPOS_UPDATE",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"CREATE TABLE TPOS_UPDATE ( C1 VARCHAR(10), C2 INTEGER PRIMARY KEY )",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"INSERT INTO TPOS_UPDATE VALUES ('AAAAAAAAAA', 1),"
                                                                 "('BBBBBBBBBB', 2),"
                                                                 "('CCCCCCCCCC', 3),"
                                                                 "('DDDDDDDDDD', 4),"
                                                                 "('EEEEEEEEEE', 5),"
                                                                 "('FFFFFFFFFF', 6),"
                                                                 "('GGGGGGGGGG', 7),"
                                                                 "('HHHHHHHHHH', 8),"
                                                                 "('IIIIIIIIII', 9),"
                                                                 "('JJJJJJJJJJ', 10),"
                                                                 "('KKKKKKKKKK', 11),"
                                                                 "('LLLLLLLLLL', 12),"
                                                                 "('MMMMMMMMMM', 13),"
                                                                 "('NNNNNNNNNN', 14)",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLSetStmtAttr( gStmtSelUpd, SQL_ATTR_CURSOR_TYPE, (SQLPOINTER)SQL_CURSOR_KEYSET_DRIVEN, 0 ) ;
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );

    rc = SQLSetStmtAttr( gStmtSelUpd, SQL_ATTR_CURSOR_SENSITIVITY, (SQLPOINTER)SQL_SENSITIVE, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );

    rc = SQLSetStmtAttr( gStmtSelUpd, SQL_ATTR_CONCURRENCY, (SQLPOINTER)SQL_CONCUR_LOCK, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );


    rc = SQLSetStmtAttr( gStmtSelUpd, SQL_ATTR_ROW_BIND_TYPE, (SQLPOINTER)SQL_BIND_BY_COLUMN, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );

    rc = SQLSetStmtAttr( gStmtSelUpd, SQL_ATTR_ROW_ARRAY_SIZE, (SQLPOINTER)ROW_ARRAY_SIZE, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );

    rc = SQLSetStmtAttr( gStmtSelUpd, SQL_ATTR_ROWS_FETCHED_PTR, (SQLPOINTER)&gNumRowsFetched, 0 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );


    rc = SQLBindCol( gStmtSelUpd, 1, SQL_C_CHAR, gCol1, sizeof( gCol1[0] ), gColInd1 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );
                             
    rc = SQLBindCol( gStmtSelUpd, 2, SQL_C_SLONG, gCol2, 0, gColInd2 );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );

    printf( "\n-- set cursor name : CUR1 --\n" );
    rc = SQLSetCursorName( gStmtSelUpd, (SQLCHAR*)"CUR1", SQL_NTS );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );
    
    printf( "\n-- select for update --\n" );
    rc = SQLExecDirect( gStmtSelUpd, (SQLCHAR*)"SELECT * FROM TPOS_UPDATE FOR UPDATE", SQL_NTS );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );

    printf( "\n-- fetch data --\n" );
    display_data( SQL_FETCH_NEXT, 0 );

    printf( "\n-- set position : 3 --\n" );
    rc = SQLSetPos( gStmtSelUpd, 3, SQL_POSITION,SQL_LOCK_NO_CHANGE );

    printf( "-- update where current of CUR1 --\n" );
    rc = SQLExecDirect( gStmt,
                        (SQLCHAR*)"UPDATE TPOS_UPDATE SET C1 = '**********', C2 = C2 + 100 WHERE CURRENT OF CUR1",
                        SQL_NTS );

    printf( "\n-- refresh data --\n" );
    display_data( SQL_FETCH_RELATIVE, 0 );

    printf( "\n-- fetch data --\n" );
    display_data( SQL_FETCH_NEXT, 0 );

    rc = SQLCloseCursor( gStmtSelUpd );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );
    
    rc = SQLFreeHandle( SQL_HANDLE_STMT, gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );
    
    rc = SQLFreeHandle( SQL_HANDLE_STMT, gStmtSelUpd );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmtSelUpd, rc );
    
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

void display_data( SQLSMALLINT aFetchOrientation,
                   SQLLEN      aFetchOffset )
{
    SQLRETURN rc;
    int       i;

    printf( "C1          C2\n" );
    printf( "---------- ---\n" );

    rc = SQLFetchScroll( gStmtSelUpd, aFetchOrientation, aFetchOffset );

    switch( rc )
    {
        case SQL_SUCCESS :
        case SQL_SUCCESS_WITH_INFO :
            for( i = 0; i < gNumRowsFetched; i++ )
            {
                if( gColInd1[i] == SQL_NULL_DATA )
                {
                    printf( "(null) " );
                }
                else
                {
                    printf( "%-11s", gCol1[i] );
                }

                if( gColInd2[i] == SQL_NULL_DATA )
                {
                    printf( "(null)\n" );
                }
                else
                {
                    printf( "%3d\n", gCol2[i] );
                }
            }
            break;
        case SQL_NO_DATA :
            printf( "no rows fetched.\n" );
            break;
        default :
            check_error( SQL_HANDLE_STMT, gStmtSelUpd, rc, __LINE__, __FILE__ );
            break;
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

    if( gStmtSelUpd != SQL_NULL_HSTMT )
    {
        (void)SQLFreeHandle( SQL_HANDLE_STMT, gStmtSelUpd );
        gStmtSelUpd = SQL_NULL_HSTMT;
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
