//##########################################
//# GOLDILOCKS Sample - DELETE
//##########################################

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* include GOLDILOCKS ODBC header */
#include <goldilocks.h>

#define GOLDILOCKS_SQL_THROW( aLabel )              \
    goto aLabel;

#define GOLDILOCKS_SQL_TRY( aExpression )           \
    do                                         \
    {                                          \
        if( !(SQL_SUCCEEDED( aExpression ) ) ) \
        {                                      \
            goto GOLDILOCKS_FINISH_LABEL;           \
        }                                      \
    } while( 0 )

#define GOLDILOCKS_FINISH                           \
    goto GOLDILOCKS_FINISH_LABEL;                   \
    GOLDILOCKS_FINISH_LABEL:

#define BUF_LEN 100

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

/* Delete funtion */
SQLRETURN testDelete( SQLHDBC aDbc )
{
    SQLHSTMT    sStmt                   = NULL;
    SQLINTEGER  sState                  = 0;
    SQLLEN      sCount                  = 0;
    SQLCHAR     sCondition[BUF_LEN];
    SQLLEN      sConditionInd           = 0;
    SQLRETURN   sReturn;

    GOLDILOCKS_SQL_TRY( SQLAllocHandle( SQL_HANDLE_STMT,
                                   aDbc,
                                   &sStmt ) );
    sState = 1;

    GOLDILOCKS_SQL_TRY( SQLPrepare( sStmt,
                               (SQLCHAR*)"DELETE FROM DEPOSIT WHERE AccountNumber = ?",
                               SQL_NTS ) );

    GOLDILOCKS_SQL_TRY( SQLBindParameter( sStmt,
                                    1,
                                    SQL_PARAM_INPUT,
                                    SQL_C_CHAR,
                                    SQL_VARCHAR,
                                    BUF_LEN,
                                    0,
                                    sCondition,
                                    sizeof( sCondition ),
                                    &sConditionInd ) );

    sConditionInd = snprintf( (char*)sCondition, 
                              BUF_LEN, 
                              "9999-99-9999" );

    /* SQLExecDirect is way to submit an SQL statement for one-time execution */
    sReturn = SQLExecute( sStmt );

    /* If SQLExecute executes a searched update, insert, or delete statement
     * that does not affect any rows at the data source,
     * the call to SQLExecute returns SQL_NO_DATA. */

    switch( sReturn )
    {
        case SQL_SUCCESS: /* Is normal. The error message does not call. */
            break;
        case SQL_SUCCESS_WITH_INFO:
            PrintDiagnosticRecord( SQL_HANDLE_STMT, sStmt );
            break;
        case SQL_NO_DATA: /* No data has been deleted. */
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

    GOLDILOCKS_SQL_TRY( SQLRowCount( sStmt, &sCount ) );

    printf( "\n%ld rows deleted.\n\n", sCount );

    /* SQLFreeHandleStmt frees resources associated with a connection */
    sState = 0;
    GOLDILOCKS_SQL_TRY( SQLFreeHandle( SQL_HANDLE_STMT, sStmt ) );

    sStmt = NULL;

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

    /* If you SQL_SUCCESS that is Delete funtion success */ 
    GOLDILOCKS_SQL_TRY( testDelete( sDbc ) );
    
    /* SQLDisconnect cloese the connection associated with a specific connection handle */
    sState = 2;
    GOLDILOCKS_SQL_TRY( SQLDisconnect( sDbc ) );

    /* SQLFreeHandleDbc frees resources associated with a connection */
    sState = 1;
    GOLDILOCKS_SQL_TRY( SQLFreeHandle( SQL_HANDLE_DBC,
                                  sDbc ) );

    sDbc = NULL;

    /* SQLFreeHandleEnv frees resources associated with a environment */
    sState = 0;
    GOLDILOCKS_SQL_TRY( SQLFreeHandle( SQL_HANDLE_ENV,
                                  sEnv ) );

    sEnv = NULL;

    printf("(DELETE_SUCCESS)\n");

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

    printf("(DELETE_FAILURE)\n");

    return EXIT_FAILURE;
}
