/*******************************************************************************
 * module.h
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

#ifndef _MODULE_H_
#define _MODULE_H_ 1

/**
 * @file module.h
 * @brief Goldilocks Python Database API functions
 */

PyObject * GetClassForThread( const char * aModuleStr,
                              const char * aClassStr );

int IsInstanceForThread( PyObject    * aParam,
                         const char  * aModuleStr,
                         const char  * aClassStr,
                         PyObject   ** aClass );

#endif /* _MODULE_H_ */
