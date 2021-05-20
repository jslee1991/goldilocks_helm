/*******************************************************************************
 * encoding.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: encoding.c 33320 2021-03-24 08:02:10Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

/**
 * @file encoding.c
 * @brief Python encoding for Goldilocks Python Database API
 */

/**
 * @addtogroup encoding
 * @{
 */

#include <pydbc.h>
#include <encoding.h>

void NormalizeCodecName( const char * aSrc,
                         char       * aDest,
                         int          aDestLen )
{
    /* encoding 앞뒤로 |를 사용. */
    /* UTF_8 --> |utf-8| */
    
    char * sCh = &aDest[0];
    char * sEndPtr = sCh + aDestLen - 2;

    *sCh = '|';
    sCh++;

    while( (*aSrc != '\0')  && (sCh < sEndPtr) )
    {
        if( isupper( *aSrc ) )
        {
            *sCh = tolower( *aSrc );
        }
        else if( *aSrc == '_' )
        {
            *sCh = '-';
        }
        else
        {
            *sCh = *aSrc;
        }

        sCh++;
        aSrc++;
    }

    *sCh = '|';
    sCh++;
    *sCh = '\0';
}

int LookupEncode( const char * aEncoding )
{
    char sLower[ENCODING_STRING_LENGTH];

    if( aEncoding == NULL )
    {
        return ENC_NONE;
    }
    
    NormalizeCodecName( aEncoding, sLower, sizeof( sLower ) );
    
    if( strstr( "|utf-8|utf8|", sLower ) != NULL )
    {
        return ENC_UTF8;
    }
    else if( strstr( "|raw|ascii|sql_ascii|", sLower ) != NULL )
    {
        return ENC_RAW;
    }
    else if( strstr( "|uhc|cp949|", sLower ) != NULL )
    {
        return ENC_CP949;
    }
    else if( strstr( "|gb18030|", sLower ) != NULL )
    {
        return ENC_GB18030;
    }
    
    return ENC_NONE;
}

PyObject * Encode( PyObject * aStr,
                   Encoding * aEncoding )
{
    PyObject * sBytes = NULL;
#if PY_MAJOR_VERSION < 3
    if(  (aEncoding->mType == ENC_RAW) || (PyBytes_Size( aStr ) == 0) )
    {
        Py_INCREF( aStr );
        return aStr;
    }
#endif

    sBytes = PyCodec_Encode( aStr, aEncoding->mName, "strict");

    if( sBytes == NULL )
    {
        return NULL;
    }

    if( PyBytes_CheckExact( sBytes ) == FALSE )
    {
        // Not all encodings return bytes.
        PyErr_Format( PyExc_TypeError,
                      "Unicode read encoding '%s' returned unexpected data type: %s",
                      aEncoding->mName,
                      Py_TYPE( sBytes )->tp_name );
        return NULL;
    }
    
    return sBytes;
}

PyObject * TextToPyObject( Encoding   * aEncoding,
                           void       * aData,
                           Py_ssize_t   aDataSize )
{
    // NB: In each branch we make a check for a zero length string and handle it specially
    // since PyUnicode_Decode may (will?) fail if we pass a zero-length string.  Issue #172
    // first pointed this out with shift_jis.  I'm not sure if it is a fault in the
    // implementation of this codec or if others will have it also.
    PyObject * sPyStr = NULL;
    int        sByteOrder = 0;
    
#if PY_MAJOR_VERSION < 3
    // The Unicode paths use the same code.
    if( aEncoding->mTo == TO_UNICODE )
    {
#endif
        if( aDataSize == 0 )
        {
            sPyStr = PyUnicode_FromStringAndSize( "", 0 );
        }
        else
        {
            switch( aEncoding->mType )
            {
                case ENC_UTF8:
                    sPyStr = PyUnicode_DecodeUTF8( (char*)aData,
                                                   aDataSize,
                                                   "strict" );
                    break;
                case ENC_UTF16:
                    sByteOrder = BYTE_ORDER_NATIVE;
                    sPyStr = PyUnicode_DecodeUTF16( (char*)aData,
                                                    aDataSize,
                                                    "strict",
                                                    &sByteOrder );
                    break;
                case ENC_UTF16LE:
                    sByteOrder = BYTE_ORDER_LE;
                    sPyStr = PyUnicode_DecodeUTF16( (char*)aData,
                                                    aDataSize,
                                                    "strict",
                                                    &sByteOrder );
                    break;
                case ENC_UTF16BE:
                    sByteOrder = BYTE_ORDER_BE;
                    sPyStr = PyUnicode_DecodeUTF16( (char*)aData,
                                                    aDataSize,
                                                    "strict",
                                                    &sByteOrder );
                    break;
                case ENC_LATIN1:
                    sPyStr = PyUnicode_DecodeLatin1( (char*)aData,
                                                     aDataSize,
                                                     "strict" );
                    break;
                default:
                    // The user set an encoding by name.
                    sPyStr = PyUnicode_Decode( (char*)aData,
                                               aDataSize,
                                               aEncoding->mName,
                                               "strict" );
                    break;
            }
        }
#if PY_MAJOR_VERSION < 3
    }
    else if( aDataSize == 0 )
    {
        sPyStr = PyString_FromStringAndSize( "", 0 );
    }
    else
    {
        sPyStr = PyString_FromStringAndSize( (char*)aData, aDataSize );
    }
#endif

    return sPyStr;
}

/**
 * @}
 */
