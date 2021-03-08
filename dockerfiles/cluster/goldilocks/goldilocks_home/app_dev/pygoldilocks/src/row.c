/*******************************************************************************
 * row.c
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id: row.c 25480 2018-07-31 07:57:03Z lkh $
 *
 * NOTES
 *
 *
 ******************************************************************************/

/**
 * @file row.c
 * @brief Python Row item for Goldilocks Python Database API
 */

/**
 * @addtogroup Row
 * @{
 */

/**
 * @brief Internal
 */

#include <pydbc.h>
#include <row.h>
#include <buffer.h>

void FreeRowValues( PyObject ** aArr )
{
    if( aArr != NULL )
    {
        free( aArr );
    }
}

static void CloseRow( Row * aRow )
{
    Py_XDECREF( aRow->mDescription );
    Py_XDECREF( aRow->mMapNameToIndex );
    aRow->mDescription = NULL;
    aRow->mMapNameToIndex = NULL;
    
    FreeRowValues( aRow->mColumnValues );
    aRow->mColumnValues = NULL;
}

static void Row_dealloc( PyObject * aSelf )
{
    // Note: Now that __newobj__ is available, our variables could be zero...

    Row * sRow = (Row *)aSelf;

    CloseRow( sRow );

    PyObject_Del( sRow );
}

static PyObject * Row_getstate( PyObject * aSelf )
{
    /**
     * Returns a tuple containing the saved state.
     * We don't really support empty rows, but unfortunately they can be
     * created now by the new constructor which was necessary for implementing pickling.
     * In that case (everything is zero), an empty tuple is returned.
     */
    // Not exposed.
    Row      * sRow = (Row *)aSelf;
    PyObject * sState;
    PyObject * sItem;
    int        i;
    
    if( sRow->mDescription == NULL )
    {
        return PyTuple_New(0);
    }

    sState = PyTuple_New( 2 + sRow->mValueCount );

    TRY( IS_VALID_PYOBJECT( sState ) != FALSE );

    PyTuple_SET_ITEM( sState, 0, sRow->mDescription );
    PyTuple_SET_ITEM( sState, 1, sRow->mMapNameToIndex );

    if( sRow->mColumnValues != NULL )
    {
        for( i = 0; i < sRow->mValueCount; i++ )
        {
            PyTuple_SET_ITEM( sState, i + 2, sRow->mColumnValues[i] );
        }

        for( i = 0; i < (sRow->mValueCount + 2); i++ )
        {
            sItem = PyTuple_GET_ITEM( sState, i );
            Py_XINCREF( sItem );
        }
    }

    return sState;

    FINISH;

    return NULL;
}

Row * MakeRowInternal( PyObject    * aDescription,
                       PyObject    * aMapNameToIndex,
                       Py_ssize_t    aValueCount,
                       PyObject   ** aColumnValues )
{
    // Called by other modules to create rows.  Takes ownership of apValues.

#ifdef _MSC_VER
#pragma warning(disable : 4365)
#endif
    Row * sRow = PyObject_NEW(Row, &gRowType);
#ifdef _MSC_VER
#pragma warning(default : 4365)
#endif

    if( sRow != NULL )
    {
        Py_INCREF( aDescription );
        sRow->mDescription = aDescription;
        
        Py_INCREF( aMapNameToIndex );
        sRow->mMapNameToIndex = aMapNameToIndex;
        sRow->mValueCount     = aValueCount;
        sRow->mColumnValues   = aColumnValues;
    }
    else
    {
        FreeRowValues( aColumnValues );
    }

    return sRow;
}

static PyObject * MakeRow( PyObject * aArgs )
{
    /**
     * We don't support a normal constructor, so only allow this for unpickling.
     * There should be a single arg that was returned by Row_reduce.
     * Make sure the sizes match.
     * The desc and map should have one entry per column, which should equal the number of remaining items.
     */
    PyObject    * sDesc;
    PyObject    * sMap;
    Py_ssize_t    sValueCount;
    PyObject   ** sColumnValues;
    int          i;

    
    TRY( PyTuple_GET_SIZE( aArgs ) >= 3 );

    sDesc = PyTuple_GET_ITEM( aArgs, 0 );
    sMap = PyTuple_GET_ITEM( aArgs, 1 );

    TRY( (PyTuple_CheckExact( sDesc ) == TRUE) && (PyDict_CheckExact( sMap ) == TRUE) );
    
    sValueCount = PyTuple_GET_SIZE( sDesc );

    TRY( (PyDict_Size( sMap ) == sValueCount) &&
         ((PyTuple_GET_SIZE( aArgs ) - 2) == sValueCount) );

    sColumnValues = (PyObject**) malloc( sizeof( PyObject*) * sValueCount );
    
    TRY( sColumnValues != NULL );

    for( i = 0; i < sValueCount; i++ )
    {
        sColumnValues[i] = PyTuple_GET_ITEM( aArgs, i + 2 );
        Py_INCREF( sColumnValues[i] );
    }
    
    /* Row_Internal will incref sDesc and sMap.
     * If something goes wrong, it will free sColumnValues.*/
    return (PyObject*)MakeRowInternal( sDesc,
                                       sMap,
                                       sValueCount,
                                       sColumnValues );

    FINISH;

    return NULL;
}

static PyObject * Row_New( PyTypeObject * aType,
                           PyObject     * aArgs,
                           PyObject     * aKeywords )
{
    PyObject * sRow = NULL;
    
    sRow = MakeRow( aArgs );

    TRY_THROW( sRow != NULL, RAMP_ERR_FAILED_CREATE );

    return sRow;

    CATCH( RAMP_ERR_FAILED_CREATE )
    {
        PyErr_SetString( PyExc_TypeError,
                         "cannot create 'pygoldilocks.Row' instances" );
    }
    
    FINISH;

    return NULL;
}



static PyObject * Row_getattr( PyObject * aObj,
                               PyObject * aName )
{
    // Called to handle 'row.colname'.

    Row        * sRow = (Row *)aObj;
    PyObject   * sIndex ;
    Py_ssize_t   i;

    TRY_THROW( sRow->mMapNameToIndex != NULL, RAMP_ERR_CLOSED );
    sIndex = PyDict_GetItem( sRow->mMapNameToIndex, aName );
    if( sIndex != NULL )
    {
        i = PyNumber_AsSsize_t( sIndex, 0 );

        TRY_THROW( sRow->mColumnValues != NULL, RAMP_ERR_CLOSED );

        Py_INCREF( sRow->mColumnValues[i] );
        return sRow->mColumnValues[i];
    }
    
    return PyObject_GenericGetAttr( aObj, aName );

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }
    
    FINISH;

    return NULL;
}


static Py_ssize_t Row_length( PyObject * aSelf )
{
    Row * sRow = (Row*)aSelf;
    if( sRow->mMapNameToIndex != NULL )
    {
        return sRow->mValueCount;
    }

    return 0;
}


static int Row_contains( PyObject * aObj,
                         PyObject * aTarget )
{
    // Implementation of contains.  The documentation is not good (non-existent?), so I copied the following from the
    // PySequence_Contains documentation: Return -1 if error; 1 if ob in seq; 0 if ob not in seq.

    Row        * sRow = (Row *)aObj;
    Py_ssize_t   i = 0;
    Py_ssize_t   sCount = sRow->mValueCount;
    int          sCmp = 0;

    TRY_THROW( sRow->mMapNameToIndex != NULL, RAMP_ERR_CLOSED );
    for( i = 0; sCmp == 0 && i < sCount; i++ )
    {
        sCmp = PyObject_RichCompareBool( aTarget, sRow->mColumnValues[i], Py_EQ );
    }

    return sCmp;

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }

    FINISH;

    return -1;
}


PyObject * Row_item( PyObject   * aObj,
                     Py_ssize_t   aIndex )
{
    // Apparently, negative indexes are handled by magic ;) -- they never make it here.

    Row * sRow = (Row *)aObj;

    TRY_THROW( (aIndex >= 0) && (aIndex < sRow->mValueCount), RAMP_ERR_OUT_RANGE );

    TRY_THROW( sRow->mColumnValues != NULL, RAMP_ERR_CLOSED );
    Py_INCREF( sRow->mColumnValues[ aIndex ] );

    return sRow->mColumnValues[ aIndex ];

    CATCH( RAMP_ERR_OUT_RANGE )
    {
        PyErr_SetString( PyExc_IndexError,
                         "Tuple index out of range" );
    }

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }
    
    FINISH;

    return NULL;
}


static int Row_ass_item( PyObject   * aObj,
                         Py_ssize_t   aIndex,
                         PyObject   * aValue )
{
    // Implements row[i] = value.

    Row * sRow = (Row *)aObj;

    TRY_THROW( (aIndex >= 0) && (aIndex < sRow->mValueCount), RAMP_ERR_OUT_RANGE );

    TRY_THROW( sRow->mColumnValues != NULL, RAMP_ERR_CLOSED );
    
    Py_XDECREF( sRow->mColumnValues[aIndex] );
    Py_INCREF( aValue );

    sRow->mColumnValues[ aIndex ] = aValue;

    return 0;

    CATCH( RAMP_ERR_OUT_RANGE )
    {
        PyErr_SetString( PyExc_IndexError,
                         "Row assignment index out of range" );
    }

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }
    
    FINISH;
    
    return -1;
}


static int Row_setattr( PyObject * aObj,
                        PyObject * aName,
                        PyObject * aValue )
{
    Row      * sRow = (Row *)aObj;
    PyObject * sIndex = NULL;

    TRY_THROW( sRow->mMapNameToIndex != NULL, RAMP_ERR_CLOSED );
    
    sIndex = PyDict_GetItem( sRow->mMapNameToIndex, aName );

    if( sIndex != NULL )
    {
        return Row_ass_item( aObj, PyNumber_AsSsize_t( sIndex, 0 ), aValue );
    }

    return PyObject_GenericSetAttr( aObj, aName, aValue );

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }
    
    FINISH;
    
    return -1;
}


static PyObject * Row_repr( PyObject * aObj )
{
    PyObject   * sTuple = NULL;
    PyObject   * sValue = NULL;
    PyObject   * sResult = NULL;
    PyObject   * sItem = NULL;
    Row        * sRow = (Row *)aObj;
    Py_ssize_t   sOffset = 0;
    Py_ssize_t   i;
    Py_ssize_t   sLength;
    TEXT_T     * sBuffer;

    TRY_THROW( sRow->mColumnValues != NULL, RAMP_ERR_CLOSED );
    
    if( sRow->mValueCount == 0 )
    {
        return PyString_FromString( "()" );
    }
    
    sTuple = PyTuple_New( sRow->mValueCount );
    TRY( IS_VALID_PYOBJECT( sTuple ) == TRUE );

    sLength = 2 + (2 * (sRow->mValueCount - 1)); // parens + ', ' separators

    for( i = 0; i < sRow->mValueCount; i++ )
    {
        sValue = PyObject_Repr( sRow->mColumnValues[i] );
        TRY( IS_VALID_PYOBJECT( sValue ) == TRUE );

        sLength += GetTextSize( sValue );

        PyTuple_SET_ITEM( sTuple, i, sValue );
    }

    if( sRow->mValueCount == 1 )
    {
        // Need a trailing comma: (value,)
        sLength += 2;
    }

    sResult = MakeText( sLength );
    TRY( IS_VALID_PYOBJECT( sResult ) == TRUE );

    sBuffer = GetTextBuffer( sResult );
    sOffset = 0;
    
    sBuffer[sOffset] = '(';
    sOffset++;
    
    for( i = 0; i < sRow->mValueCount; i++ )
    {
        sItem = PyTuple_GET_ITEM( sTuple, i );
        memcpy( &sBuffer[sOffset], GetTextBuffer( sItem ), GetTextSize( sItem ) * sizeof(TEXT_T) );
        sOffset += GetTextSize( sItem );

        if( (i != ( sRow->mValueCount - 1 )) || (sRow->mValueCount == 1) )
        {
            sBuffer[sOffset++] = ',';
            sBuffer[sOffset++] = ' ';
        }
    }
    sBuffer[sOffset++] = ')';

    DASSERT(sOffset == sLength);

    Py_XDECREF( sTuple );

    return sResult;

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }
    
    FINISH;

    Py_XDECREF( sTuple );
    
    return NULL;
}


static PyObject * Row_richcompare( PyObject * aRow1,
                                   PyObject * aRow2,
                                   int   aOp )
{
    Row        * sRow1;
    Row        * sRow2;
    Py_ssize_t   i = 0;
    Py_ssize_t   sCount;
    bool         sResult;
    PyObject   * sRet;
    
    if( (ROW_CHECK(aRow1) != TRUE) || (ROW_CHECK(aRow2) != TRUE) )
    {
        Py_INCREF( Py_NotImplemented );
        return Py_NotImplemented;
    }

    sRow1 = (Row *)aRow1;
    sRow2 = (Row *)aRow2;

    if( sRow1->mValueCount != sRow2->mValueCount )
    {
        // Different sizes, so use the same rules as the tuple class.
        switch( aOp )
        {
            case Py_EQ:
                sResult = (sRow1->mValueCount == sRow2->mValueCount);
                break;
            case Py_GE:
                sResult = (sRow1->mValueCount >= sRow2->mValueCount);
                break;
            case Py_GT:
                sResult = (sRow1->mValueCount >  sRow2->mValueCount);
                break;
            case Py_LE:
                sResult = (sRow1->mValueCount <= sRow2->mValueCount);
                break;
            case Py_LT:
                sResult = (sRow1->mValueCount <  sRow2->mValueCount);
                break;
            case Py_NE:
                sResult = (sRow1->mValueCount != sRow2->mValueCount);
                break;
            default:
                // Can't get here, but don't have a cross-compiler way to silence this.
                sResult = FALSE;
        }
        
        sRet = sResult ? Py_True : Py_False;
        Py_INCREF( sRet );
        return sRet;
    }

    TRY_THROW( sRow1->mColumnValues != NULL, RAMP_ERR_CLOSED );
    TRY_THROW( sRow2->mColumnValues != NULL, RAMP_ERR_CLOSED );
    
    for( i = 0, sCount = sRow1->mValueCount; i < sCount; i++ )
    {
        if( PyObject_RichCompareBool(sRow1->mColumnValues[i],
                                     sRow2->mColumnValues[i],
                                     Py_EQ) != TRUE )
        {
            return PyObject_RichCompare( sRow1->mColumnValues[i], sRow2->mColumnValues[i], aOp );
        }
    }

    // All items are equal.
    switch( aOp )
    {
        case Py_EQ:
        case Py_GE:
        case Py_LE:
            Py_RETURN_TRUE;

        case Py_GT:
        case Py_LT:
        case Py_NE:
            break;
    }

    Py_RETURN_FALSE;

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }
    
    FINISH;

    return NULL;
}


static PyObject * Row_subscript( PyObject * aObj,
                                 PyObject * aKey )
{
    PyObject   * sResult = NULL;
    Row        * sRow = (Row*)aObj;
    Py_ssize_t   i;
    Py_ssize_t   sStart;
    Py_ssize_t   sStop;
    Py_ssize_t   sStep;
    Py_ssize_t   sSliceLength;
    Py_ssize_t   sIndex;

    TRY_THROW( sRow->mColumnValues != NULL, RAMP_ERR_CLOSED );
    
    if( PyIndex_Check( aKey ) == TRUE )
    {
        i = PyNumber_AsSsize_t( aKey, PyExc_IndexError );

        TRY( (i != -1) || (!PyErr_Occurred()) );
        
        if( i < 0 )
        {
            i += sRow->mValueCount;
        }

        TRY_THROW( (i >= 0) && (i < sRow->mValueCount), RAMP_ERR_OUT_RANGE );
        
        Py_INCREF( sRow->mColumnValues[i]);
        return sRow->mColumnValues[i];
    }

    if( PySlice_Check( aKey ) == TRUE )
    {
        i = 0;

#if PY_VERSION_HEX >= 0x03020000
        TRY( PySlice_GetIndicesEx( aKey,
                                   sRow->mValueCount,
                                   &sStart,
                                   &sStop,
                                   &sStep,
                                   &sSliceLength ) >= 0 );
#else
        TRY( PySlice_GetIndicesEx( (PySliceObject*)aKey,
                                   sRow->mValueCount,
                                   &sStart,
                                   &sStop,
                                   &sStep,
                                   &sSliceLength ) >= 0 );
#endif

        if( sSliceLength <= 0 )
        {
            return PyTuple_New(0);
        }
        
        if( (sStart == 0) && (sStep == 1) && (sSliceLength == sRow->mValueCount) )
        {
            Py_INCREF( aObj );
            return aObj;
        }

        sResult = PyTuple_New( sSliceLength );
        TRY( IS_VALID_PYOBJECT( sResult ) == TRUE );

        for( i = 0, sIndex = sStart; i < sSliceLength; i++, sIndex += sStep )
        {
            PyTuple_SET_ITEM( sResult, i, sRow->mColumnValues[sIndex] );
            Py_INCREF( sRow->mColumnValues[sIndex] );
        }

        return sResult;
    }

    return PyErr_Format( PyExc_TypeError,
                         "row indices must be integers, not %.200s",
                         Py_TYPE(aKey)->tp_name );

    CATCH( RAMP_ERR_OUT_RANGE )
    {
        PyErr_Format( PyExc_IndexError,
                      "row index out of range index=%d len=%d",
                      (int)i,
                      (int)sRow->mValueCount );
    }

    CATCH( RAMP_ERR_CLOSED )
    {
        PyErr_SetString( ProgrammingError,
                         "The Row is closed." );
    }
    
    FINISH;

    return NULL;
}


static PySequenceMethods Row_as_sequence =
{
    Row_length,      // sq_length
    0,               // sq_concat
    0,               // sq_repeat
    Row_item,        // sq_item
    0,               // was_sq_slice
    Row_ass_item,    // sq_ass_item
    0,               // sq_ass_slice
    Row_contains,    // sq_contains
};


static PyMappingMethods Row_as_mapping =
{
    Row_length,      // mp_length
    Row_subscript,   // mp_subscript
    0,               // mp_ass_subscript
};


static char gDescriptionDoc[] = "The Cursor.description sequence from the Cursor that created this row.";

static PyMemberDef gRow_members[] =
{
    {
        "cursor_description",
        T_OBJECT_EX,
        OFFSETOF( Row, mDescription),
        READONLY,
        gDescriptionDoc
    },

    { NULL, 0, 0, 0, NULL }
};

static PyObject * Row_reduce( PyObject * aSelf,
                              PyObject * aArgs )
{
    PyObject * sState = Row_getstate( aSelf );
    
    TRY( sState != NULL );
    
    return Py_BuildValue( "ON", Py_TYPE( aSelf ), sState );

    FINISH;

    return NULL;
}

static char gCloseDoc[] =
    "Close the row to free memory.\n";
static PyObject * Row_close( PyObject * aSelf,
                             PyObject * aArgs )
{
    Row * sRow = NULL;

    sRow = (Row*) aSelf;

    CloseRow( sRow );
    
    TRY( !PyErr_Occurred() );

    Py_RETURN_NONE;

    FINISH;

    return NULL;
}

static PyMethodDef gRow_methods[] =
{
    { "__reduce__", (PyCFunction)Row_reduce, METH_NOARGS, NULL },
    { "close", (PyCFunction)Row_close, METH_NOARGS, gCloseDoc },
    { 0, 0, 0, 0 }
};

static char RowDoc[] =
    "Row objects are sequence objects that hold query results.\n"
    "\n"
    "They are similar to tuples in that they cannot be resized and new attributes\n"
    "cannot be added, but individual elements can be replaced.  This allows data to\n"
    "be \"fixed up\" after being fetched.  (For example, datetimes may be replaced by\n"
    "those with time zones attached.)\n"
    "\n"
    "  row[0] = row[0].replace(tzinfo=timezone)\n"
    "  print row[0]\n"
    "\n"
    "Additionally, individual values can be optionally be accessed or replaced by\n"
    "name.  Non-alphanumeric characters are replaced with an underscore.\n"
    "\n"
    "  cursor.execute(\"select customer_id, [Name With Spaces] from tmp\")\n"
    "  row = cursor.fetchone()\n"
    "  print row.customer_id, row.Name_With_Spaces\n"
    "\n"
    "If using this non-standard feature, it is often convenient to specifiy the name\n"
    "using the SQL 'as' keyword:\n"
    "\n"
    "  cursor.execute(\"select count(*) as total from tmp\")\n"
    "  row = cursor.fetchone()\n"
    "  print row.total";

PyTypeObject gRowType =
{
    PyVarObject_HEAD_INIT(NULL, 0)
    "pygoldilocks.Row",    // tp_name
    sizeof(Row),                         // tp_basicsize
    0,                                   // tp_itemsize
    Row_dealloc,                         // tp_dealloc
    0,                                   // tp_print
    0,                                   // tp_getattr
    0,                                   // tp_setattr
    0,                                   // tp_compare
    Row_repr,                            // tp_repr
    0,                                   // tp_as_number
    &Row_as_sequence,                    // tp_as_sequence
    &Row_as_mapping,                     // tp_as_mapping
    0,                                   // tp_hash
    0,                                   // tp_call
    0,                                   // tp_str
    Row_getattr,                        // tp_getattr
    Row_setattr,                        // tp_setattr
    0,                                   // tp_as_buffer
    Py_TPFLAGS_DEFAULT,                  // tp_flags
    RowDoc,                              // tp_doc
    0,                                   // tp_traverse
    0,                                   // tp_clear
    Row_richcompare,                     // tp_richcompare
    0,                                   // tp_weaklistoffset
    0,                                   // tp_iter
    0,                                   // tp_iternext
    gRow_methods,                        // tp_methods
    gRow_members,                        // tp_members
    0,                                   // tp_getset
    0,                                   // tp_base
    0,                                   // tp_dict
    0,                                   // tp_descr_get
    0,                                   // tp_descr_set
    0,                                   // tp_dictoffset
    0,                                   // tp_init
    0,                                   // tp_alloc
    Row_New,                             // tp_new
    0,                                   // tp_free
    0,                                   // tp_is_gc
    0,                                   // tp_bases
    0,                                   // tp_mro
    0,                                   // tp_cache
    0,                                   // tp_subclasses
    0,                                   // tp_weaklist
};

/**
 * @}
 */
