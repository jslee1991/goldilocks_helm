/*******************************************************************************
 * param.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: param.h 25480 2018-07-31 07:57:03Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

#ifndef _PARAM_H_
#define _PARAM_H_ 1

/**
 * @file param.h
 * @brief Python Parameters for Goldilocks Python Database API
 */

STATUS FreeParameterInfos( Cursor * aCursor );

STATUS InitParams();

STATUS Prepare( Cursor   * aCursor,
                PyObject * aSql );

STATUS PrepareAndBind( Cursor   * aCursor,
                       PyObject * aSql,
                       PyObject * aOrgParams,
                       bool       aSkipFirst );

bool GetParameterInfo( Cursor     * aCursor,
                       Py_ssize_t   aIndex,
                       PyObject   * aParam,
                       ParamInfo  * aInfo );

STATUS GetInOutParameterData( Cursor     * aCursor,
                              Py_ssize_t   aIndex,
                              PyObject   * aParam,
                              ParamInfo  * aParamInfo );

STATUS MakeOutputParameter( Cursor       * aCursor,
                            PyObject     * aParamSeq,
                            PyObject    ** aOutParam,
                            PsmParamInfo * aPsmParamInfo );

STATUS BindParameter( Cursor      * aCursor,
                      Py_ssize_t    aIndex,
                      SQLSMALLINT   aInputOutputType,
                      ParamInfo   * aParamInfo );

STATUS ExecuteMulti( Cursor   * aCursor,
                     PyObject * aSql,
                     PyObject * aParamArrObj );

STATUS FreeParameter( Cursor * aCursor );

#endif /* _PARAM_H_ */
