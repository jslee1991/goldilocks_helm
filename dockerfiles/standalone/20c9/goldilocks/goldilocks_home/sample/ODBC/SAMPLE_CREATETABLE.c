//##########################################
//# GOLDILOCKS Sample - CREATETABLE
//##########################################

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* include GOLDILOCKS ODBC header */
#include <goldilocks.h>

#define GOLDILOCKS_SQL_THROW( aLable )               \
    goto aLable;

#define GOLDILOCKS_SQL_TRY( aExpression )            \
    do                                          \
    {                                           \
        if( !(SQL_SUCCEEDED( aExpression ) ) )  \
        {                                       \
            goto GOLDILOCKS_FINISH_LABEL;            \
        }                                       \
    } while( 0 )

#define GOLDILOCKS_FINISH                            \
    goto GOLDILOCKS_FINISH_LABEL;                    \
    GOLDILOCKS_FINISH_LABEL:

/* Print diagnostic record to console  */
void PrintDiagnosticRecord(SQLSMALLINT aHandleType, SQLHANDLE aHandle)
{
    SQLCHAR       sSQLState[6];
    SQLINTEGER    sNativeError;
    SQLSMALLINT   sTextLength;
    SQLCHAR       sMessageText[SQL_MAX_MESSAGE_LENGTH];
    SQLSMALLINT   sRecNumber = 1;
    SQLRETURN     sReturn;
    
    /* SQLGetDiagRec returns the currrent values that contains error, warning */
    while( 1 )
    {
        sReturn = SQLGetDiagRec( aHandleType,
                                 aHandle,
                                 sRecNumber,
                                 sSQLState,
                                 &sNativeError,
                                 sMessageText,
                                 100,
                                 &sTextLength );

        if( sReturn == SQL_NO_DATA )
        {
            break;
        }

        GOLDILOCKS_SQL_TRY( sReturn );

        printf("\n=============================================\n" );
        printf("SQL_DIAG_SQLSTATE     : %s\n", sSQLState );
        printf("SQL_DIAG_NATIVE       : %d\n", sNativeError );
        printf("SQL_DIAG_MESSAGE_TEXT : %s\n", sMessageText );
        printf("=============================================\n" );

        sRecNumber++;
    }

    return;

    GOLDILOCKS_FINISH;

    printf("SQLGetDiagRec failure.\n" );

    return;    
}

/* CreateTable funtion */
SQLRETURN testCreateTable( SQLHDBC aDbc )
{
    SQLHSTMT    sStmt  = NULL;
    SQLINTEGER  sState = 0;
    SQLRETURN   sReturn;

    GOLDILOCKS_SQL_TRY( SQLAllocHandle( SQL_HANDLE_STMT,
                                   aDbc,
                                   &sStmt ) );
    sState = 1;

    /* SQLExecDirect is way to submit an SQL statement for one-time execution */
    sReturn = SQLExecDirect( sStmt,
                             (SQLCHAR*)"CREATE TABLE DEPOSIT ("
                             " NAME          VARCHAR(30),"
                             " BALANCE       INTEGER,"
                             " ACCOUNTNUMBER VARCHAR(100),"
                             " ACCOUNTDAY    DATE,"
                             " INTERESTRATES NATIVE_REAL,"
                             " PHONENUMBER   VARCHAR(30) )",
                             SQL_NTS );

    switch( sReturn )
    {
        case SQL_SUCCESS: /* Is normal. The error message does not call. */
            break;
        case SQL_SUCCESS_WITH_INFO:
            PrintDiagnosticRecord( SQL_HANDLE_STMT, sStmt );
            break;
        case SQL_NEED_DATA:
            /* FALL-THROUGH */ /* Error message is output. */
        case SQL_STILL_EXECUTING:
            /* FALL-THROUGH */ /* Error message is output. */
        case SQL_ERROR:
            /* FALL-THROUGH */ /* Error message is output. */
        case SQL_INVALID_HANDLE:
            GOLDILOCKS_SQL_THROW( GOLDILOCKS_FINISH_LABEL );
            break;
        default : /* Returns the value of the unknown */
            GOLDILOCKS_SQL_THROW( GOLDILOCKS_FINISH_LABEL );
            break;
    }

    /* SQLFreeHandleStmt frees resources associated with a connection */
    sState = 0;
    GOLDILOCKS_SQL_TRY( SQLFreeHandle( SQL_HANDLE_STMT, sStmt ) );

    sStmt = NULL;

    printf( "\nTable created.\n\n");
    return SQL_SUCCESS;


    GOLDILOCKS_FINISH;

    switch(sState)
    {
        case 1:
            PrintDiagnosticRecord( SQL_HANDLE_STMT, sStmt );
            (void)SQLFreeHandle( SQL_HANDLE_STMT, sStmt );
            sStmt = NULL;
        default:
            break;
    }

    return SQL_ERROR;
}

/* Start funtion */
int main( int aArgc, char** aArgv )
{
    SQLHENV     sEnv    = NULL;
    SQLHDBC     sDbc    = NULL;
    SQLINTEGER  sState  = 0;

    /* If you call SQLAllocEnv() that is included in GOLDILOCKS ODBC*/
    GOLDILOCKS_SQL_TRY( SQLAllocHandle( SQL_HANDLE_ENV,
                                   NULL,
                                   &sEnv ) );
    sState = 1;

    /* SQLSetEnvAttr is sets attributes that govern aspects of environments */
    GOLDILOCKS_SQL_TRY( SQLSetEnvAttr( sEnv,
                                  SQL_ATTR_ODBC_VERSION,
                                  (SQLPOINTER)SQL_OV_ODBC3,
                                  0 ) );

    /* If you call SQLAllocDbc that is mapped in the Driver Manager to SQLConnect */
    GOLDILOCKS_SQL_TRY( SQLAllocHandle( SQL_HANDLE_DBC,
                                   sEnv,
                                   &sDbc ) );
    sState = 2;

    /* SQLConnect establishes connections to a driver and a data source */
    GOLDILOCKS_SQL_TRY( SQLConnect( sDbc,
                               (SQLCHAR*)"GOLDILOCKS",
                               SQL_NTS,
                               (SQLCHAR*)"test",
                               SQL_NTS,
                               (SQLCHAR*)"test",
                               SQL_NTS) );
    sState = 3;

    /* If you SQL_SUCCESS that is CreateTable funtion success */ 
    GOLDILOCKS_SQL_TRY( testCreateTable( sDbc ) );

    /* SQLDisconnect cloese the connection associated with a specific connection handle */
    sState = 2;
    GOLDILOCKS_SQL_TRY( SQLDisconnect( sDbc ) );


    /* SQLFreeHandleDbc frees resources associated with a connection */
    sState = 1;
    GOLDILOCKS_SQL_TRY( SQLFreeHandle( SQL_HANDLE_DBC,
                                  sDbc ) );

    sDbc = NULL;

    sState = 0;
    /* SQLFreeHandleEnv frees resources associated with a environment */
    GOLDILOCKS_SQL_TRY( SQLFreeHandle( SQL_HANDLE_ENV,
                                  sEnv ) );

    sEnv = NULL;

    printf("(CREATETABLE_SUCCESS)\n");

    return EXIT_SUCCESS;

    GOLDILOCKS_FINISH;

    if( sDbc != NULL)
    {
        PrintDiagnosticRecord( SQL_HANDLE_DBC, sDbc );
    }
    if( sEnv != NULL)
    {
        PrintDiagnosticRecord( SQL_HANDLE_ENV, sEnv );
    }

    switch( sState )
    {
        case 3:
            /* SQLDisconnect cloese the connection associated with a specific connection handle */
            (void)SQLDisconnect( sDbc );
        case 2:
            /* SQLFreeHandleDbc frees resources associated with a connection */
            (void)SQLFreeHandle( SQL_HANDLE_DBC, sDbc );
            sDbc = NULL;
        case 1:
            /* SQLFreeHandleEnv frees resources associated with a environment */
            (void)SQLFreeHandle( SQL_HANDLE_ENV, sEnv );
            sEnv = NULL;
        default:
            break;
    }

    printf("(CREATETABLE_FAILURE)\n");
    
    return EXIT_FAILURE;
}
