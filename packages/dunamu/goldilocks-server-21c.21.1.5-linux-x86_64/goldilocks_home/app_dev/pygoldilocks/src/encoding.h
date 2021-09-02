/*******************************************************************************
 * encoding.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id$
 *
 * NOTES
 *
 *
 ******************************************************************************/

#ifndef _ENCODING_H_
#define _ENCODING_H_ 1

/**
 * @file encoding.h
 * @brief Encoding for Goldilocks Python Database API
 */

void NormalizeCodecName( const char * aSrc,
                         char       * aDest,
                         int          aDestLen );

int LookupEncode( const char * aEncodingName );

PyObject * Encode( PyObject * aStr,
                   Encoding * aEncoding );

/**
 * Convert a text buffer to a Python object using the given encoding.
 *
 * The buffer can be a SQLCHAR array or SQLWCHAR array.  The text encoding should match it.
 */
PyObject * TextToPyObject( Encoding   * aEncoding,
                           void       * aData,
                           Py_ssize_t   aDataSize );


#endif /* _ENCODING_H_ */
