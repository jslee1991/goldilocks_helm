//##########################################
//# GOLDILOCKS Sample - SELECT
//##########################################

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* include GOLDILOCKS ODBC header */
#include <goldilocks.h>

/* User-specific Definitions */
#define  BUF_LEN          100
#define  MAX_COLUMN_COUNT 1024

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

#define GOLDILOCKS_FINISH                            \
    goto GOLDILOCKS_FINISH_LABEL;                    \
    GOLDILOCKS_FINISH_LABEL:

/* Column structure is as follows. */
typedef struct COLUMN_STRUCT
{
    SQLCHAR      ColName[BUF_LEN];
    SQLSMALLINT  ColNameLen;
    SQLSMALLINT  ColType;
    SQLULEN      ColSize;
    SQLSMALLINT  ColDecimalDigits;
    SQLSMALLINT  ColNullablePtr;
    SQLLEN       ColOctetLength;
    SQLINTEGER   ColLeadingPrecision;
}COLUMN_STRUCT;

/* Data structure is as follows. */
typedef struct DATA_STRUCT
{
    SQLLEN       DataInd;
    SQLSMALLINT  DataType;
    union 
    {
        SQLCHAR                            DataChar[BUF_LEN];
        SQLSMALLINT                        DataSmallInt;
        SQLINTEGER                         DataInteger;
        SQLBIGINT                          DataBigInt;
        SQLREAL                            DataReal;
        SQLDOUBLE                          DataDouble;
        SQL_NUMERIC_STRUCT                 DataNumeric;
        SQLBOOLEAN                         DataBoolean;
        SQL_DATE_STRUCT                    DataDate;
        SQL_TIME_STRUCT                    DataTime;
        SQL_TIME_WITH_TIMEZONE_STRUCT      DataTimeTZ;
        SQL_TIMESTAMP_STRUCT               DataTimeStamp;
        SQL_TIMESTAMP_WITH_TIMEZONE_STRUCT DataTimeStampTZ;
        SQL_INTERVAL_STRUCT                DataInterval;
    } Data;
}DATA_STRUCT;

/* Column Data structure is as follows. */
typedef struct COLUMN_DATA_STRUCT
{
    COLUMN_STRUCT  ColInformation;
    DATA_STRUCT    DataValue;
}COLUMN_DATA_STRUCT;

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

    printf("SQLGetDiagRec() failure.\n" );

    return;
}

/*
 * Code that implements the conversion from little endian mode to the
 * scaled integer.
 *
 * Please note that it is up to the application developer to implement this
 * functionality. The example here is just one of the many possible ways.
 *
 * http://support.microsoft.com/kb/222831
 */

long strtohextoval( SQL_NUMERIC_STRUCT * aNumStr )
{
    long value = 0;

    int  i =1;
    
    int  last =1;
    int  current;
    
    int  a = 0;
    int  b = 0;

    for( i = 0; i <= 15; i++ )
    {
        current = (int)aNumStr->val[i];
        a       = current % 16; //Obtain LSD
        b       = current / 16; //Obtain MSD
				
        value += last* a;	
        last   = last * 16;	
        value += last* b;
        last   = last * 16;	
    }

    return value;
}

/* Select funtion */
SQLRETURN testSelect( SQLHDBC aDbc )
{
    SQLHSTMT                sStmt                           = NULL;
    SQLHDESC                sARD                            = NULL;
    SQLHDESC                sIRD                            = NULL;
    SQLINTEGER              sState                          = 0;
    SQLPOINTER              sData                           = NULL;
    COLUMN_DATA_STRUCT      sColData[MAX_COLUMN_COUNT];
    SQLSMALLINT             sColCount                       = 0;
    SQLCHAR                 sDataBuffer[BUF_LEN];
    SQLLEN                  sCount                          = 0;
    SQLRETURN               sReturn;
    int                     i                               = 0;
    int                     j                               = 0;
    int                     sSign                           = 1;
    long                    sNumericValue                   = 0;
    long                    sDivisor                        = 1;
    float                   sFinalValue                     = 0;

    GOLDILOCKS_SQL_TRY( SQLAllocHandle( SQL_HANDLE_STMT,
                                   aDbc,
                                   &sStmt ) );
    sState = 1;
    
    /* SQLGetStmtAttr returns the current setting of a statement attribute. */
    GOLDILOCKS_SQL_TRY( SQLGetStmtAttr( sStmt,
                                   SQL_ATTR_APP_ROW_DESC,
                                   &sARD,
                                   SQL_IS_POINTER,
                                   NULL )
                    == SQL_SUCCESS );

    GOLDILOCKS_SQL_TRY( SQLGetStmtAttr( sStmt,
                                   SQL_ATTR_IMP_ROW_DESC,
                                   &sIRD,
                                   SQL_IS_POINTER,
                                   NULL )
                    == SQL_SUCCESS );

     /* SQLExecDirect is way to submit an SQL statement for one-time execution */
    GOLDILOCKS_SQL_TRY( SQLExecDirect( sStmt,
                                  (SQLCHAR*)"SELECT * FROM Deposit",
                                  SQL_NTS ) );

    /* SQLNumResultCols returns the number of columns in a result set. */
    GOLDILOCKS_SQL_TRY( SQLNumResultCols( sStmt,
                                     &sColCount ) );

    /* SQLDescribeCol returns the result descriptor — column name,type, 
     * column size, decimal digits, and nullability — for one column in the result set. */    
    for( i = 1; i <= sColCount; i ++ )
    {
        GOLDILOCKS_SQL_TRY( SQLDescribeCol( sStmt,
                                       i,
                                       sColData[i].ColInformation.ColName,
                                       BUF_LEN,
                                       &sColData[i].ColInformation.ColNameLen,
                                       &sColData[i].ColInformation.ColType,
                                       &sColData[i].ColInformation.ColSize,
                                       &sColData[i].ColInformation.ColDecimalDigits,
                                       &sColData[i].ColInformation.ColNullablePtr ) );

        GOLDILOCKS_SQL_TRY( SQLGetDescField( sIRD,
                                        i,
                                        SQL_DESC_OCTET_LENGTH,
                                        &sColData[i].ColInformation.ColOctetLength,
                                        0,
                                        NULL )
                        == SQL_SUCCESS );
    }

    for( i = 1; i <= sColCount; i ++ )
    {
        /* Conversion type(SQL type -> SQL_C type), and specify variables. */
        
        /*
         *  C Data Types :
         * http://msdn.microsoft.com/en-us/library/windows/desktop/ms714556%28v=vs.85%29.aspx
         * Converting Data from C to SQL Data Types : 
         * http://msdn.microsoft.com/en-us/library/windows/desktop/ms716298%28v=vs.85%29.aspx
         */
        switch( sColData[i].ColInformation.ColType )
        {
            case SQL_CHAR:
                /* FALL_THROUGH */ /* Variables used 'SQLCHAR type' is. */
            case SQL_VARCHAR:
                /* FALL_THROUGH */ /* Variables used 'SQLCHAR type' is. */
            case SQL_BINARY:
                /* FALL_THROUGH */ /* Variables used 'SQLCHAR type' is. */
            case SQL_VARBINARY:
                /* FALL_THROUGH */ /* Variables used 'SQLCHAR type' is. */
            case SQL_ROWID:
                sColData[i].DataValue.DataType = SQL_C_CHAR;
                sData = &sColData[i].DataValue.Data.DataChar;
                break;
            case SQL_SMALLINT: /* 'SQL_SMALLINT' type */
                sColData[i].DataValue.DataType = SQL_C_SHORT;
                sData = &sColData[i].DataValue.Data.DataSmallInt;
                break;
            case SQL_INTEGER: /* 'SQL_INTEGER' type */
                sColData[i].DataValue.DataType = SQL_C_LONG;
                sData = &sColData[i].DataValue.Data.DataInteger;
                break;
            case SQL_BIGINT: /* 'SQL_BIGINT' type */
                sColData[i].DataValue.DataType = SQL_C_SBIGINT;
                sData = &sColData[i].DataValue.Data.DataBigInt;
                break;
            case SQL_NUMERIC: /* 'SQL_NUMERIC' type */
                sColData[i].DataValue.DataType = SQL_C_NUMERIC;
                sData = &sColData[i].DataValue.Data.DataNumeric;
                break;
            case SQL_REAL: /* 'SQL_REAL' type */
                sColData[i].DataValue.DataType = SQL_C_FLOAT;
                sData = &sColData[i].DataValue.Data.DataReal;
                break;
            case SQL_DOUBLE: /* 'SQL_DOUBLE' type */
                sColData[i].DataValue.DataType = SQL_C_DOUBLE;
                sData = &sColData[i].DataValue.Data.DataDouble;
                break;
            case SQL_BOOLEAN: /* 'SQL_BOOLEAN' type */
                sColData[i].DataValue.DataType = SQL_C_BOOLEAN;
                sData = &sColData[i].DataValue.Data.DataBoolean;
                break;
            case SQL_TYPE_DATE: /* 'SQL_TYPE_DATE' type */
                sColData[i].DataValue.DataType = SQL_C_TYPE_DATE;
                sData = &sColData[i].DataValue.Data.DataDate;
                break;
            case SQL_TYPE_TIME: /* 'SQL_TYPE_TIME' type */
                sColData[i].DataValue.DataType = SQL_C_TYPE_TIME;
                sData = &sColData[i].DataValue.Data.DataTime;
                break;
            case SQL_TYPE_TIME_WITH_TIMEZONE: /* 'SQL_TYPE_TIME_WITH_TIMEZONE' type */
                sColData[i].DataValue.DataType = SQL_C_TYPE_TIME_WITH_TIMEZONE;
                sData = &sColData[i].DataValue.Data.DataTimeTZ;
                break;
            case SQL_TYPE_TIMESTAMP: /* 'SQL_TYPE_TIMESTAMP' type */
                sColData[i].DataValue.DataType = SQL_C_TYPE_TIMESTAMP;
                sData = &sColData[i].DataValue.Data.DataTimeStamp;
                break;
            case SQL_TYPE_TIMESTAMP_WITH_TIMEZONE: /* 'SQL_TYPE_TIMESTAMP_WITH_TIMEZONE' type */
                sColData[i].DataValue.DataType = SQL_C_TYPE_TIMESTAMP_WITH_TIMEZONE;
                sData = &sColData[i].DataValue.Data.DataTimeStampTZ;
                break;
            case SQL_INTERVAL_YEAR: /* 'SQL_INTERVAL_YEAR' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_YEAR;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_MONTH: /* 'SQL_INTERVAL_MONTH' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_MONTH;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_DAY: /* 'SQL_INTERVAL_DAY' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_DAY;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_HOUR: /* 'SQL_INTERVAL_HOUR' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_HOUR;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_MINUTE: /* 'SQL_INTERVAL_MINUTE' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_MINUTE;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_SECOND: /* 'SQL_INTERVAL_SECOND' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_SECOND;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_YEAR_TO_MONTH: /* 'SQL_INTERVAL_YEAR_TO_MONTH' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_YEAR_TO_MONTH;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_DAY_TO_HOUR: /* 'SQL_INTERVAL_DAY_TO_HOUR' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_DAY_TO_HOUR;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_DAY_TO_MINUTE: /* 'SQL_INTERVAL_DAY_TO_MINUTE' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_DAY_TO_MINUTE;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_DAY_TO_SECOND: /* 'SQL_INTERVAL_DAY_TO_SECOND' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_DAY_TO_SECOND;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_HOUR_TO_MINUTE: /* 'SQL_INTERVAL_HOUR_TO_MINUTE' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_HOUR_TO_MINUTE;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_HOUR_TO_SECOND: /* 'SQL_INTERVAL_HOUR_TO_SECOND' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_HOUR_TO_SECOND;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            case SQL_INTERVAL_MINUTE_TO_SECOND: /* 'SQL_INTERVAL_MINUTE_TO_SECOND' type */
                sColData[i].DataValue.DataType = SQL_C_INTERVAL_MINUTE_TO_SECOND;
                sData = &sColData[i].DataValue.Data.DataInterval;
                break;
            default: /* Unknown data type */
                GOLDILOCKS_SQL_THROW( GOLDILOCKS_FINISH_LABEL );
                break;
        }

        /*
         * SQLBindCol binds application data buffers to columns in the result set.
         *
         * If the TargetType argument is an interval data type,
         * the default interval leading precision (2) and the default interval seconds precision (6),
         * as set in the SQL_DESC_DATETIME_INTERVAL_PRECISION and SQL_DESC_PRECISION fields of the ARD,
         * respectively, are used for the data.
         *
         * If the TargetType argument is SQL_C_NUMERIC, the default precision (driver-defined) and default scale (0),
         * as set in the SQL_DESC_PRECISION and SQL_DESC_SCALE fields of the ARD, are used for the data.
         *
         * If any default precision or scale is not appropriate,
         * the application should explicitly set the appropriate descriptor field by a call to SQLSetDescField or SQLSetDescRec.
         */ 
        GOLDILOCKS_SQL_TRY( SQLBindCol( sStmt,
                                   i,
                                   sColData[i].DataValue.DataType,
                                   sData,
                                   sColData[i].ColInformation.ColOctetLength,
                                   &sColData[i].DataValue.DataInd ) );

        switch( sColData[i].DataValue.DataType )
        {
            case SQL_C_NUMERIC :
                /*
                 * Set the datatype, precision and scale fields of the descriptor for the numeric column.
                 * Otherwise the default precision (driver defined) and scale (0) are returned.
                 */
                GOLDILOCKS_SQL_TRY( SQLSetDescField( sARD,
                                                i,
                                                SQL_DESC_PRECISION,
                                                (SQLPOINTER)sColData[i].ColInformation.ColSize,
                                                0 ) );
                
                GOLDILOCKS_SQL_TRY( SQLSetDescField( sARD,
                                                i,
                                                SQL_DESC_SCALE,
                                                (SQLPOINTER)(long)sColData[i].ColInformation.ColDecimalDigits,
                                                0 ) );

                GOLDILOCKS_SQL_TRY( SQLSetDescField( sARD,
                                                i,
                                                SQL_DESC_DATA_PTR,
                                                (SQLPOINTER)sData,
                                                0 ) );
                break;
            case SQL_INTERVAL_YEAR:
            case SQL_INTERVAL_MONTH:
            case SQL_INTERVAL_DAY:
            case SQL_INTERVAL_HOUR:
            case SQL_INTERVAL_MINUTE:
            case SQL_INTERVAL_SECOND:
            case SQL_INTERVAL_YEAR_TO_MONTH:
            case SQL_INTERVAL_DAY_TO_HOUR:
            case SQL_INTERVAL_DAY_TO_MINUTE:
            case SQL_INTERVAL_DAY_TO_SECOND:
            case SQL_INTERVAL_HOUR_TO_MINUTE:
            case SQL_INTERVAL_HOUR_TO_SECOND:
            case SQL_INTERVAL_MINUTE_TO_SECOND:
                GOLDILOCKS_SQL_TRY( SQLGetDescField( sIRD,
                                                i,
                                                SQL_DESC_DATETIME_INTERVAL_PRECISION,
                                                (void*)&sColData[i].ColInformation.ColLeadingPrecision,
                                                SQL_IS_INTEGER,
                                                0 ) );
                                                 
                GOLDILOCKS_SQL_TRY( SQLSetDescField( sARD,
                                                i,
                                                SQL_DESC_DATETIME_INTERVAL_PRECISION,
                                                (void*)(long)sColData[i].ColInformation.ColLeadingPrecision,
                                                0 ) );
            case SQL_TYPE_TIME:
            case SQL_TYPE_TIME_WITH_TIMEZONE:
            case SQL_TYPE_TIMESTAMP:
            case SQL_TYPE_TIMESTAMP_WITH_TIMEZONE:
                GOLDILOCKS_SQL_TRY( SQLSetDescField( sARD,
                                                i,
                                                SQL_DESC_PRECISION,
                                                (void*)(long)sColData[i].ColInformation.ColDecimalDigits,
                                                0 ) );

                GOLDILOCKS_SQL_TRY( SQLSetDescField( sARD,
                                                i,
                                                SQL_DESC_DATA_PTR,
                                                (SQLPOINTER)sData,
                                                0 ) );
            default:
                break;
        }
    }
    
    /* Column names will be printed. */
    printf( "\n" );
    for( i = 1; i <= sColCount; i ++ )
    {
            printf( "%-15s  ", sColData[i].ColInformation.ColName );
    }
    printf( "\n" );
    
    for( i = 1; i <= sColCount; i ++ )
    {
            printf( "---------------  " );
    }
    printf( "\n" );
    
    /* Data will be printed. */
    while( 1 )
    {
        sReturn = SQLFetch( sStmt );

        if( sReturn == SQL_NO_DATA )
        {
            break;
        }

        GOLDILOCKS_SQL_TRY( sReturn );

        for( i = 1; i <= sColCount; i ++ )
        {
            /* The output format depends on the type of data. */
            switch( sColData[i].DataValue.DataType )
            {
                case SQL_C_CHAR:
                    /* check null data */ 
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        printf( "%-15s  ", sColData[i].DataValue.Data.DataChar );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_SHORT:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        printf( "%15d  ", sColData[i].DataValue.Data.DataSmallInt );
                    }
                    else
                    {
                        printf( "%15s  ", "(null)" );
                    }
                    break;
                case SQL_C_LONG:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        printf( "%15d  ", sColData[i].DataValue.Data.DataInteger );
                    }
                    else
                    {
                        printf( "%15s  ", "(null)" );
                    }
                    break;
                case SQL_C_SBIGINT:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        printf( "%15ld  ", sColData[i].DataValue.Data.DataBigInt );
                    }
                    else
                    {
                        printf( "%15s  ", "(null)" );
                    }
                    break;
                case SQL_C_NUMERIC:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        /*
                         * Call to convert the little endian mode data into numeric data.
                         */
                        sNumericValue = strtohextoval( &sColData[i].DataValue.Data.DataNumeric );

                        /*
                         * The returned value in the above code is scaled to the value specified
                         * in the scale field of the numeric structure. For example 25.212 would
                         * be returned as 25212. The scale in this case is 3 hence the integer
                         * value needs to be divided by 1000.
                         */
                        sDivisor = 1;

                        if( sColData[i].DataValue.Data.DataNumeric.scale > 0 )
                        {
                            for( j = 0; j <  sColData[i].DataValue.Data.DataNumeric.scale; j++ )
                            {
                                sDivisor = sDivisor * 10;
                            }
                            
                            sFinalValue = (float)sNumericValue / (float)sDivisor;
                        }
                        else
                        {
                            for( j = sColData[i].DataValue.Data.DataNumeric.scale; j < 0; j++ )
                            {
                                sDivisor = sDivisor * 10;
                            }
                            
                            sFinalValue = (float)sNumericValue * (float)sDivisor;
                        }

                        /*
                         * Examine the sign value returned in the sign field for the numeric structure.
                         * NOTE: The ODBC 3.0 spec required drivers to return the sign as
                         * 1 for positive numbers and 2 for negative number. This was changed in the
                         * ODBC 3.5 spec to return 0 for negative instead of 2.
                         */

                        if( sColData[i].DataValue.Data.DataNumeric.sign == 0 )
                        {
                            sSign = -1;
                        }
                        else
                        {
                            sSign = 1;
                        }

                        sFinalValue *= sSign;

                        printf( "%15.3f  ", sFinalValue );
                    }
                    else
                    {
                        printf( "%15s  ", "(null)" );
                    }
                    break;
                case SQL_C_FLOAT:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        printf( "%15.3f  ", sColData[i].DataValue.Data.DataReal );
                    }
                    else
                    {
                        printf( "%15s  ", "(null)" );
                    }
                    break;
                case SQL_C_DOUBLE:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        printf( "%15.3f  ", sColData[i].DataValue.Data.DataDouble );
                    }
                    else
                    {
                        printf( "%15s  ", "(null)" );
                    }
                    break;
                case SQL_C_BOOLEAN:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        printf( "%-15s  ",
                                sColData[i].DataValue.Data.DataBoolean ? "true" : "false" );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_TYPE_DATE:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        (void)snprintf( (char*)sDataBuffer,
                                        BUF_LEN,
                                        "%-4d-%02d-%02d",
                                        sColData[i].DataValue.Data.DataDate.year,
                                        sColData[i].DataValue.Data.DataDate.month,
                                        sColData[i].DataValue.Data.DataDate.day );
                        printf( "%-15s  ", sDataBuffer );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_TYPE_TIME:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        (void)snprintf( (char*)sDataBuffer,
                                        BUF_LEN,
                                        "%02d:%02d:%02d",
                                        sColData[i].DataValue.Data.DataTime.hour,
                                        sColData[i].DataValue.Data.DataTime.minute,
                                        sColData[i].DataValue.Data.DataTime.second );
                        printf( "%-15s  ", sDataBuffer );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_TYPE_TIME_WITH_TIMEZONE:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        (void)snprintf( (char*)sDataBuffer,
                                        BUF_LEN,
                                        "%02u:%02u:%02u.%u +%02d:%02d",
                                        sColData[i].DataValue.Data.DataTimeTZ.hour,
                                        sColData[i].DataValue.Data.DataTimeTZ.minute,
                                        sColData[i].DataValue.Data.DataTimeTZ.second,
                                        sColData[i].DataValue.Data.DataTimeTZ.fraction,
                                        sColData[i].DataValue.Data.DataTimeTZ.timezone_hour,
                                        sColData[i].DataValue.Data.DataTimeTZ.timezone_minute );
                        printf( "%-15s  ", sDataBuffer );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_TYPE_TIMESTAMP:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        (void)snprintf( (char*)sDataBuffer,
                                        BUF_LEN,
                                        "%d-%02d-%02d %02d:%02d:%02d.%u",
                                        sColData[i].DataValue.Data.DataTimeStamp.year,
                                        sColData[i].DataValue.Data.DataTimeStamp.month,
                                        sColData[i].DataValue.Data.DataTimeStamp.day,
                                        sColData[i].DataValue.Data.DataTimeStamp.hour,
                                        sColData[i].DataValue.Data.DataTimeStamp.minute,
                                        sColData[i].DataValue.Data.DataTimeStamp.second,
                                        sColData[i].DataValue.Data.DataTimeStamp.fraction );
                        printf( "%-15s  ", sDataBuffer );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_TYPE_TIMESTAMP_WITH_TIMEZONE:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        (void)snprintf( (char*)sDataBuffer,
                                        BUF_LEN,
                                        "%u-%02u-%02u %02u:%02u:%02u.%u +%02d:%02d",
                                        sColData[i].DataValue.Data.DataTimeStampTZ.year,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.month,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.day,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.hour,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.minute,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.second,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.fraction,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.timezone_hour,
                                        sColData[i].DataValue.Data.DataTimeStampTZ.timezone_minute );
                        printf( "%-15s  ", sDataBuffer );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_INTERVAL_YEAR:
                    /* FALL_THROUGH */ /* 'Interval_year_month' series use the same format */
                case SQL_C_INTERVAL_MONTH:
                    /* FALL_THROUGH */ /* 'Interval_year_month' series use the same format */
                case SQL_C_INTERVAL_YEAR_TO_MONTH:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        (void)snprintf( (char*)sDataBuffer,
                                        BUF_LEN,
                                        "%d-%02d",
                                        sColData[i].DataValue.Data.DataInterval.intval.year_month.year,
                                        sColData[i].DataValue.Data.DataInterval.intval.year_month.month );
                        printf( "%-15s  ", sDataBuffer );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                case SQL_C_INTERVAL_DAY:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_HOUR:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_MINUTE:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_SECOND:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_DAY_TO_HOUR:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_DAY_TO_MINUTE:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_DAY_TO_SECOND:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_HOUR_TO_MINUTE:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_HOUR_TO_SECOND:
                    /* FALL_THROUGH */ /* 'Interval_day_second' series use the same format */
                case SQL_C_INTERVAL_MINUTE_TO_SECOND:
                    /* check null data */
                    if( sColData[i].DataValue.DataInd != SQL_NULL_DATA )
                    {
                        (void)snprintf( (char*)sDataBuffer,
                                        BUF_LEN,
                                        "%d %02d:%02d:%02d",
                                        sColData[i].DataValue.Data.DataInterval.intval.day_second.day,
                                        sColData[i].DataValue.Data.DataInterval.intval.day_second.hour,
                                        sColData[i].DataValue.Data.DataInterval.intval.day_second.minute,
                                        sColData[i].DataValue.Data.DataInterval.intval.day_second.second );
                        printf( "%-15s  ", sDataBuffer );
                    }
                    else
                    {
                        printf( "%-15s  ", "(null)" );
                    }
                    break;
                default : /* Unknown data type */
                    printf( "Unknown data type : %d\n", sColData[i].DataValue.DataType );
                    GOLDILOCKS_SQL_THROW( GOLDILOCKS_FINISH_LABEL );
                    break;
            }

            if( i == sColCount )
            {
                printf( "\n");
            }
        }

        /* SQLFetch () is the result of 'SQL_SUCCESS_WITH_INFO', then the error message is output. */
        if( sReturn == SQL_SUCCESS_WITH_INFO )
        {
            PrintDiagnosticRecord( SQL_HANDLE_STMT, sStmt );
        }

        sCount ++;
    }
    printf( "\n%ld rows selected.\n\n", sCount );

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
    SQLHENV     sEnv = NULL;
    SQLHDBC     sDbc = NULL;
    SQLINTEGER  sState = 0;

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

    /* If you SQL_SUCCESS that is Select funtion success */ 
    GOLDILOCKS_SQL_TRY( testSelect( sDbc ) );
    
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

    printf("(SELECT_SUCCESS)\n");

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

    printf("(SELECT_FAILURE)\n");

    return EXIT_FAILURE;
}
