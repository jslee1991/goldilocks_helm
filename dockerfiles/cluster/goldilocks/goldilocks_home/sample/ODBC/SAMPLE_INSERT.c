//##########################################
//# GOLDILOCKS Sample - INSERT
//##########################################

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* include GOLDILOCKS ODBC header */
#include <goldilocks.h>

/* User-specific Definitions */
#define  BUF_LEN 100

#define GOLDILOCKS_SQL_THROW( aLabel )               \
    goto aLabel;

#define GOLDILOCKS_SQL_TRY( aExpression )            \
    do                                          \
    {                                           \
        if( !(SQL_SUCCEEDED( aExpression ) ) )  \
        {                                       \
            goto GOLDILOCKS_FINISH_LABEL;            \
        }                                       \
    } while( 0 )

#define GOLDILOCKS_FINISH                           \
    goto GOLDILOCKS_FINISH_LABEL;                   \
    GOLDILOCKS_FINISH_LABEL:

/* Print diagnostic record to console  */
void PrintDiagnosticRecord( SQLSMALLINT aHandleType, SQLHANDLE aHandle )
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

/* Insert funtion */
SQLRETURN testInsert( SQLHDBC aDbc )
{
    SQLHSTMT            sStmt                       = NULL;
    SQLINTEGER          sState                      = 0;
    SQLCHAR             sName[BUF_LEN];
    SQLLEN              sNameInd                    = 0;
    SQLINTEGER          sBalance                    = 0;
    SQLLEN              sBalanceInd                 = 0;
    SQLCHAR             sAccountNumber[BUF_LEN];
    SQLLEN              sAccountNumberInd           = 0;
    SQL_DATE_STRUCT     sAccountDay;
    SQLLEN              sAccountDayInd              = 0;
    SQLREAL             sInterestRates              = 0;
    SQLLEN              sInterestRatesInd           = 0;
    SQLCHAR             sPhoneNumber[BUF_LEN];
    SQLLEN              sPhoneNumberInd             = 0;
    SQLLEN              sCount                      = 0;
    SQLRETURN           sReturn;

    /* If you call SQLAllocDbc that is mapped in the statement*/
    GOLDILOCKS_SQL_TRY( SQLAllocHandle( SQL_HANDLE_STMT,
                                   aDbc,
                                   &sStmt ) );
    sState = 1;

    /* SQLPrepare prepare an SQL string for execution */
    GOLDILOCKS_SQL_TRY( SQLPrepare( sStmt,
                               (SQLCHAR*)"INSERT INTO Deposit VALUES(?, ?, ?, ?, ?, ?)",
                               SQL_NTS ) );

    /* SQLBindParameter binds a buffer to a parameter marker in an SQL statement */
    GOLDILOCKS_SQL_TRY( SQLBindParameter( sStmt,
                                     1,
                                     SQL_PARAM_INPUT,
                                     SQL_C_CHAR,
                                     SQL_VARCHAR,
                                     30,
                                     0,
                                     sName,
                                     sizeof(sName),
                                     &sNameInd ) );
    GOLDILOCKS_SQL_TRY( SQLBindParameter( sStmt,
                                     2,
                                     SQL_PARAM_INPUT,
                                     SQL_C_SLONG,
                                     SQL_INTEGER,
                                     0,
                                     0,
                                     &sBalance,
                                     sizeof(sBalance),
                                     &sBalanceInd ) );
    GOLDILOCKS_SQL_TRY( SQLBindParameter( sStmt,
                                     3,
                                     SQL_PARAM_INPUT,
                                     SQL_C_CHAR,
                                     SQL_VARCHAR,
                                     100,
                                     0,
                                     sAccountNumber,
                                     sizeof(sAccountNumber),
                                     &sAccountNumberInd ) );
    GOLDILOCKS_SQL_TRY( SQLBindParameter( sStmt,
                                     4,
                                     SQL_PARAM_INPUT,
                                     SQL_C_TYPE_DATE,
                                     SQL_TYPE_DATE,
                                     0,
                                     0,
                                     &sAccountDay,
                                     sizeof(sAccountDay),
                                     &sAccountDayInd ) );
    GOLDILOCKS_SQL_TRY( SQLBindParameter( sStmt,
                                     5,
                                     SQL_PARAM_INPUT,
                                     SQL_C_FLOAT,
                                     SQL_REAL,
                                     0,
                                     0,
                                     &sInterestRates,
                                     sizeof(sInterestRates),
                                     &sInterestRatesInd ) );
    GOLDILOCKS_SQL_TRY( SQLBindParameter( sStmt,
                                     6,
                                     SQL_PARAM_INPUT,
                                     SQL_C_CHAR,
                                     SQL_VARCHAR,
                                     30,
                                     0,
                                     sPhoneNumber,
                                     sizeof(sPhoneNumber),
                                     &sPhoneNumberInd ) );

    sNameInd              = snprintf( (char*)sName, BUF_LEN, "sunje" );
    sBalance              = 30000000;
    sAccountNumberInd     = snprintf( (char*)sAccountNumber, BUF_LEN, "9999-99-9999" );
    sAccountDay.year      = 2009;
    sAccountDay.month     = 1;
    sAccountDay.day       = 1;
    sInterestRates        = (SQLREAL)5.0;
    sPhoneNumberInd       = snprintf( (char*)sPhoneNumber, BUF_LEN, "010-9999-9999" );

    /* SQLExecute executes a prepared statement */
    sReturn = SQLExecute( sStmt );

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
        default : /* Returns the value for the unknown */
            GOLDILOCKS_SQL_THROW( GOLDILOCKS_FINISH_LABEL );
            break;
    }

    /* SQLRowCount return the number of rows affected by an INSERT statement */
    GOLDILOCKS_SQL_TRY( SQLRowCount( sStmt, &sCount) );
    printf("\n%ld row created.\n\n", sCount );
    
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
    SQLHENV    sEnv    = NULL;
    SQLHDBC    sDbc    = NULL;
    SQLINTEGER sState  = 0;

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

    /* If you SQL_SUCCESS that is Insert funtion success */ 
    GOLDILOCKS_SQL_TRY( testInsert( sDbc ) );
    
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

    printf( "(INSERT_SUCCESS)\n" );

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

    printf( "(INSERT_FAILURE)\n" );
    
    return EXIT_FAILURE;
}
