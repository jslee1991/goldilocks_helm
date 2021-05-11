#include <goldilocks.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void check_error( SQLSMALLINT, SQLHANDLE, SQLRETURN, int, char *);
void print_error( SQLSMALLINT, SQLHANDLE, SQLRETURN, int, char *);
void cleanup();

#define CHECK_HANDLE( aHandleType, aHandle, rc )                        \
    if( rc != SQL_SUCCESS )                                             \
    {                                                                   \
        check_error( aHandleType, aHandle , rc , __LINE__, __FILE__);   \
        cleanup();                                                      \
        return -1;                                                      \
    }

#define BUFFER_SIZE 1024

char   gBuffer[BUFFER_SIZE + 1];
FILE * gFilePtr = NULL;

SQLHENV  gEnv  = SQL_NULL_HENV;
SQLHDBC  gDbc  = SQL_NULL_HDBC;
SQLHSTMT gStmt = SQL_NULL_HSTMT;

int main( int argc, char ** argv )
{
    SQLRETURN rc;
    SQLRETURN ret;
    
    SQLLEN sParamLength  = 0;
    SQLLEN Strlen_or_Ind = SQL_NTS;

    SQLPOINTER sToken;
    
    char * sFileName  = NULL;
    int    sChunkSize = 0;
    
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
    
    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"DROP TABLE IF EXISTS TLONGVARCHAR",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"CREATE TABLE TLONGVARCHAR ( C1 LONG VARCHAR )",
                        SQL_NTS ); 
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    /*
     * Sending Long Data
     */
    
    sFileName = "LongData.c";

    gFilePtr = fopen( sFileName, "r" );
    
    if( gFilePtr == NULL ) 
    {
        printf( "Error opening file %s\n", sFileName );
        return -1;
    }

    rc = SQLBindParameter( gStmt,
                           1,
                           SQL_PARAM_INPUT,
                           SQL_C_CHAR,
                           SQL_LONGVARCHAR,
                           0,
                           0,
                           (SQLPOINTER)1,
                           0,
                           &sParamLength );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    sParamLength = SQL_DATA_AT_EXEC;

    printf( "-- Sending Long Data --\n" );
    rc = SQLPrepare( gStmt, 
                     (SQLCHAR*)"INSERT INTO TLONGVARCHAR VALUES (?)",
                     SQL_NTS );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLExecute( gStmt );

    if( rc != SQL_NEED_DATA )
    {
        CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
    }
    
    rc = SQLParamData( gStmt, &sToken );

    if( rc != SQL_NEED_DATA )
    {
        CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
    }
        
    while( !feof(gFilePtr) ) 
    {
        sChunkSize = fread( gBuffer, 1, BUFFER_SIZE, gFilePtr);
                
        if( ferror(gFilePtr) != 0 ) 
        {
            printf( "IO error\n" );
            return -1;
        }
                
        if( sChunkSize != 0 ) 
        {
            printf( "putting %4d bytes\n", sChunkSize );
                    
            ret = SQLPutData( gStmt, gBuffer, sChunkSize );
            CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, ret );
        }
    }
    
    rc = SQLParamData( gStmt, &sToken );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    rc = SQLFreeHandle( SQL_HANDLE_STMT, gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );

    gStmt = SQL_NULL_HANDLE;
    
    if( fclose(gFilePtr) != 0 )
    {
        printf( "Error closing file %s\n", sFileName );
        return -1;
    }
    
    /*
     * Getting Long Data
     */
    
    rc = SQLAllocStmt( gDbc,&gStmt );
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
    
    printf( "\n\n-- Getting Long Data --\n" );
    rc = SQLExecDirect( gStmt, 
                        (SQLCHAR*)"SELECT C1 FROM TLONGVARCHAR",
                        SQL_NTS);
    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
    
    while( 1 )
    {
        rc = SQLFetch( gStmt );
        
        if( rc == SQL_NO_DATA ) 
        {
            rc = SQLCloseCursor( gStmt );
            CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
            
            break;
        }

        if( rc == SQL_ERROR )
        {
            CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, rc );
        }
        
        while( 1 )
        {
            Strlen_or_Ind = SQL_NTS;
            
            ret = SQLGetData( gStmt,
                              1,
                              SQL_C_CHAR,
                              gBuffer,
                              BUFFER_SIZE,
                              &Strlen_or_Ind);

            if( ret == SQL_NO_DATA )
            {
                break;
            }

            switch( ret )
            {
                case SQL_SUCCESS :
                case SQL_SUCCESS_WITH_INFO :
                    if( Strlen_or_Ind == SQL_NULL_DATA )
                    {
                        printf( "null\n" );
                    }
                    else
                    {
                        printf( "%s", gBuffer );
                    }
                    break;
                default :
                    CHECK_HANDLE( SQL_HANDLE_STMT, gStmt, ret );
                    break;
            }
            
            if( rc == SQL_ERROR )
            {
                break;
            }
        }
    }
    
    printf( "\n\n---DONE fetching---\n\n" );
    
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
