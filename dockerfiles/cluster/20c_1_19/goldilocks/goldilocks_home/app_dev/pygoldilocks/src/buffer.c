/*******************************************************************************
 * buffer.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: buffer.c 25480 2018-07-31 07:57:03Z lkh $
 *
 * NOTES
 *
 *
 **************************S****************************************************/

/**
 * @file buffer.c
 * @brief Python Parameter's buffer for Goldilocks Python Database API
 */

/**
 * @addtogroup Buffer
 * @{
 */

/**
 * @brief Internal
 */

#include <pydbc.h>
#include <buffer.h>

void ToLower( char * aStr )
{
    while( *aStr )
    {
        if( isascii( *aStr ) == TRUE )
        {
            *aStr = tolower( *aStr );
        }

        aStr++;
    }
}

bool IsLowerCase()
{
    return PyObject_GetAttrString( gModule, "lowercase") == Py_True;
}

#if PY_MAJOR_VERSION < 3

Py_ssize_t GetBufferMemory( PyObject  * aBuffer,
                            char     ** aPtr )
{
#if PY_VERSION_HEX >= 0x02050000
    char       * sPtr = NULL;
#else
    const char * sPtr = NULL;
#endif
    Py_ssize_t      sLen;
    PyBufferProcs * sProcs = Py_TYPE( aBuffer )->tp_as_buffer;

    // Can't access the memory directly because the buffer object doesn't support it.
    TRY( (sProcs != NULL) &&
         (PyType_HasFeature( Py_TYPE(aBuffer), Py_TPFLAGS_HAVE_GETCHARBUFFER ) != 0) );

    // Can't access the memory directly because there is more than one segment.
    TRY( sProcs->bf_getsegcount( aBuffer, NULL ) == 1 );

    sLen = sProcs->bf_getcharbuffer( aBuffer, 0, &sPtr);

    if( aPtr != NULL )
    {
        *aPtr = sPtr;
    }

    return sLen;

    FINISH;

    return -1;
}

Py_ssize_t GetBufferSize( PyObject * aSelf )
{
    Py_ssize_t      sTotalLen = 0;
    PyBufferProcs * sProcs = Py_TYPE( aSelf )->tp_as_buffer;
    
    TRY_THROW( PyBuffer_Check( aSelf ) != FALSE, RAMP_ERR_NOT_BUFFER );

    TRY( sProcs != NULL );
    sProcs->bf_getsegcount( aSelf, &sTotalLen );

    return sTotalLen;

    CATCH( RAMP_ERR_NOT_BUFFER )
    {
        PyErr_SetString( PyExc_TypeError, "Not a buffer!" );
    }

    FINISH;

    return 0;
}

/**
 * PyObject의 Buffer를 얻는다.
 */ 
void InitBufSegIterator( BufSegIterator * aIterator,
                         PyObject       * aBuffer )
{
    PyBufferProcs * sProcs;

    sProcs = Py_TYPE( aBuffer )->tp_as_buffer;

    aIterator->mBuffer   = aBuffer;
    aIterator->mSegment  = 0;
    aIterator->mSegCount = sProcs->bf_getsegcount(aIterator->mBuffer, 0);
}

bool GetNextBufSegIterator( BufSegIterator  * aIterator,
                            char           ** aPtr,
                            SQLLEN          * aSize )
{
    PyBufferProcs * sProcs;

    TRY( aIterator->mSegment < aIterator->mSegCount );

    sProcs = Py_TYPE(aIterator->mBuffer)->tp_as_buffer;

    /**
     * getreadbuffer는 3rd 인자에 결과 buffer를 반환. 
     */
    *aSize = sProcs->bf_getreadbuffer( aIterator->mBuffer,
                                       aIterator->mSegment++,
                                       (void**)aPtr );

    return TRUE;

    FINISH;

    return FALSE;
}
#endif

#if PY_MAJOR_VERSION >= 3
void PyString_ConcatAndDel( PyObject ** aDest, PyObject * aTarget )
{
    PyUnicode_Concat( *aDest, aTarget );
    Py_DECREF( aTarget );
}
#endif

bool IsEqualText( PyObject   * aObj,
                  const char * aText )
{
    Py_ssize_t   sObjSize;
    Py_ssize_t   sTextSize;
    Py_UNICODE * sUni;
    Py_ssize_t   i = 0;
    int          sUniInt = 0;
    int          sTxtInt = 0;

#if PY_MAJOR_VERSION < 3
    // In Python 2, allow ANSI strings.
    if( (aObj != NULL) && PyString_Check( aObj ))
    {
        return strcasecmp( PyString_AS_STRING( aObj ), aText ) == 0;
    }
#endif

    if( (aObj == NULL) || (PyUnicode_Check( aObj ) == FALSE) )
    {
        return FALSE;
    }
    
    sObjSize = PyUnicode_GET_SIZE( aObj );
    sTextSize = (Py_ssize_t)strlen( aText );
    
    if( sObjSize != sTextSize )
    {
        return FALSE;
    }
    
    sUni = PyUnicode_AS_UNICODE( aObj );
    for( i = 0; i < sObjSize; i++ )
    {
        sUniInt = (int)Py_UNICODE_TOUPPER( sUni[i]);
        sTxtInt = (int)toupper( aText[i] );
        
        if( sUniInt != sTxtInt )
        {
            return FALSE;
        }
    }

    return TRUE;
}

PyObject * MakeText( Py_ssize_t aLength )
{
    // Returns a new, uninitialized String (Python 2) or Unicode object (Python 3) object.
#if PY_MAJOR_VERSION < 3
    return PyString_FromStringAndSize( 0, aLength );
#else
    return PyUnicode_FromUnicode( 0, aLength);
#endif
}

TEXT_T * GetTextBuffer( PyObject * aObj )
{
#if PY_MAJOR_VERSION < 3
    DASSERT( PyString_Check( aObj ) );
    return PyString_AS_STRING( aObj );
#else
    DASSERT( PyUnicode_Check( aObj ) );
    return PyUnicode_AS_UNICODE( aObj );
#endif
}


Py_ssize_t GetTextSize( PyObject * aObj )
{
#if PY_MAJOR_VERSION < 3
    if( (aObj != NULL) && (PyString_Check(aObj) == TRUE) )
    {
        return PyString_GET_SIZE( aObj );
    }
#endif
    if( (aObj != NULL) && (PyUnicode_Check( aObj ) == TRUE) )
    {
        return PyUnicode_GET_SIZE( aObj );
    }
    
    return 0;
}

Py_ssize_t CopyTextToUnicode( Py_UNICODE * aBuffer,
                              PyObject   * aObj )
{
    /**
     * Copies a String or Unicode object to a Unicode buffer and returns the number
     * of characters copied.  No NULL terminator is appended!
     */
    Py_ssize_t   sSize = 0;
    
#if PY_MAJOR_VERSION < 3
    Py_ssize_t   i = 0;
    char       * sPtr = NULL;

    if( PyBytes_Check( aObj ) )
    {
        sSize = PyBytes_GET_SIZE( aObj );
        sPtr  = PyBytes_AS_STRING( aObj );

        for( i = 0; i < sSize; i++ )
        {
            *aBuffer++ = (Py_UNICODE)*sPtr++;
        }

        return sSize;
    }
    else
    {
#endif
        sSize = PyUnicode_GET_SIZE( aObj );
        memcpy( aBuffer, PyUnicode_AS_UNICODE( aObj ), sSize * sizeof( Py_UNICODE ) );
        return sSize;
#if PY_MAJOR_VERSION < 3
    }
#endif
}


/**
 * @}
 */
