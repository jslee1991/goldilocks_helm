/*******************************************************************************
 * buffer.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: buffer.h 26607 2018-12-20 09:45:10Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

#ifndef _BUFFER_H_
#define _BUFFER_H_ 1

/**
 * @file buffer.h
 * @brief Python Parameter's buffer for Goldilocks Python Database API
 */

#include <pydbc.h>

#ifdef _MSC_VER
#define  strcasecmp _strcmpi
#endif

#if defined(__SUNPRO_CC) || defined(__SUNPRO_C) ||defined(__GNUC__) 
#include <alloca.h>
#define CDECL cdecl
#define _alloca alloca
void ToLower( char * aStr );
#else
#define CDECL
#endif

#define IS_SET( aValue, aFlags )                            \
    (((int)(aValue) & (int)(aFlags)) == (int)(aFlags))

bool IsLowerCase( void );

#if PY_MAJOR_VERSION < 3

/**
 * If the buffer object has a single, accessible segment, returns the length of the buffer.
 * If 'aPtr' is not NULL, the address of the segment is also returned.
 * If there is more than one segment or if it cannot be accessed, -1 is returned and
 * 'aPtr' is not modified.
 */
Py_ssize_t GetBufferMemory( PyObject  * aBuffer,
                            char     ** aPtr );

/**
 * Returns the size of a Python buffer.
 * If an error occurs, zero is returned, but zero is a valid buffer size (I guess),
 * so use PyErr_Occurred to determine if it represents a failure.
 */
Py_ssize_t GetBufferSize( PyObject * aSelf );

void InitBufSegIterator( BufSegIterator * aIterator,
                         PyObject       * aBuffer );
bool GetNextBufSegIterator( BufSegIterator * aIterator,
                            char          ** aPtr,
                            SQLLEN         * aSize );

#endif // PY_MAJOR_VERSION

#if PY_VERSION_HEX >= 0x03000000 && PY_VERSION_HEX < 0x03010000
#error Python 3.0 is not supported.  Please use 3.1 and higher.
#endif

// Macros introduced in 2.6, backported for 2.4 and 2.5.
#ifndef PyVarObject_HEAD_INIT
#define PyVarObject_HEAD_INIT(type, size) PyObject_HEAD_INIT(type) size,
#endif

#ifndef Py_TYPE
#define Py_TYPE(ob) (((PyObject*)(ob))->ob_type)
#endif

// Macros were introduced in 2.6 to map "bytes" to "str" in Python 2.  Back port to 2.5.
#if PY_VERSION_HEX >= 0x02060000
    #include <bytesobject.h>
#else
    #define PyBytes_AS_STRING PyString_AS_STRING
    #define PyBytes_Check PyString_Check
    #define PyBytes_CheckExact PyString_CheckExact
    #define PyBytes_FromStringAndSize PyString_FromStringAndSize
    #define PyBytes_GET_SIZE PyString_GET_SIZE
    #define PyBytes_Size PyString_Size
    #define _PyBytes_Resize _PyString_Resize
#endif

// Used for items that are ANSI in Python 2 and Unicode in Python 3 or in int 2 and long in 3.

#if PY_MAJOR_VERSION >= 3
  #define PyString_FromString PyUnicode_FromString
  #define PyString_FromStringAndSize PyUnicode_FromStringAndSize
  #define PyString_Check PyUnicode_Check
  #define PyString_Type PyUnicode_Type
  #define PyString_Size PyUnicode_Size
  #define PyInt_FromLong PyLong_FromLong
  #define PyInt_AsLong PyLong_AsLong
  #define PyInt_AS_LONG PyLong_AS_LONG
  #define PyInt_Type PyLong_Type
  #define PyString_FromFormatV PyUnicode_FromFormatV
  #define PyString_FromFormat PyUnicode_FromFormat
  #define Py_TPFLAGS_HAVE_ITER 0

  #define PyString_AsString PyUnicode_AsString

  #define TEXT_T Py_UNICODE

  #define PyString_Join PyUnicode_Join

void PyString_ConcatAndDel(PyObject** lhs, PyObject* rhs);

#else
  #include <stringobject.h>
  #include <intobject.h>
  #include <bufferobject.h>

  #define TEXT_T char

  #define PyString_Join _PyString_Join

#endif

// Case-insensitive comparison for a Python string object (Unicode in Python 3, ASCII or Unicode in Python 2) against an ASCII string.  If lhs is 0 or None, false is returned.
bool IsEqualText( PyObject * aObj, const char * aText );

PyObject * MakeText( Py_ssize_t aLength );
TEXT_T * GetTextBuffer( PyObject * aObj );

Py_ssize_t GetTextSize( PyObject * aObj );
Py_ssize_t CopyTextToUnicode( Py_UNICODE * aBuffer, PyObject * aObj );


#endif /* _BUFFER_H_ */
