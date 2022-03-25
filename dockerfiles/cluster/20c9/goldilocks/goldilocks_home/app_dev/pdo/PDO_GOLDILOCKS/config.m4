dnl $Id$
dnl config.m4 for extension pdo_goldilocks
dnl vim:et:sw=2:ts=2:

PHP_ARG_WITH(pdo-goldilocks, for GOLDILOCKS support for PDO,
[  --with-pdo-goldilocks=DIR
                          PDO: GOLDILOCKS support. DIR defaults to \$GOLDILOCKS_HOME.])

if test "$PHP_PDO_GOLDILOCKS" != "no"; then

  if test "$PHP_PDO" = "no" && test "$ext_shared" = "no"; then
    AC_MSG_ERROR([PDO is not enabled! Add --enable-pdo to your configure line.])
  fi

  AC_MSG_CHECKING([GOLDILOCKS Install-Dir])
  if test "$PHP_PDO_GOLDILOCKS" = "yes" || test -z "$PHP_PDO_GOLDILOCKS"; then
    PDO_GOLDILOCKS_DIR=$GOLDILOCKS_HOME
  else
    PDO_GOLDILOCKS_DIR=$PHP_PDO_GOLDILOCKS
  fi
  AC_MSG_RESULT($PHP_PDO_GOLDILOCKS)

  if test -z "$PDO_GOLDILOCKS_DIR"; then
    AC_MSG_ERROR(Cannot find GOLDILOCKS in known installation directories)
  fi

  PDO_GOLDILOCKS_INCDIR="$PDO_GOLDILOCKS_DIR/include"
  PDO_GOLDILOCKS_LIBDIR="$PDO_GOLDILOCKS_DIR/lib"

  if test ! -d "$PDO_GOLDILOCKS_INCDIR"; then
    AC_MSG_ERROR(include dir $PDO_GOLDILOCKS_INCDIR does not exist)
  fi

  if test ! -d "$PDO_GOLDILOCKS_LIBDIR"; then
    AC_MSG_ERROR(library dir $GOLDILOCKS_LIBDIR does not exist)
  fi

  if test "$ext_shared" = "no"; then
    PDO_GOLDILOCKS_LIB="gdlc"

    if test ! -r "$PDO_GOLDILOCKS_LIBDIR/lib$PDO_GOLDILOCKS_LIB.a"; then
       AC_MSG_ERROR(Could not find $PDO_GOLDILOCKS_LIBDIR/lib$PDO_GOLDILOCKS_LIB.a GOLDILOCKS library)
    fi
  else
    PDO_GOLDILOCKS_LIB="gdlcs"

    if test ! -r "$PDO_GOLDILOCKS_LIBDIR/lib$PDO_GOLDILOCKS_LIB.$SHLIB_SUFFIX_NAME"; then
       AC_MSG_ERROR(Could not find $PDO_GOLDILOCKS_LIBDIR/lib$PDO_GOLDILOCKS_LIB.$SHLIB_SUFFIX_NAME GOLDILOCKS library)
    fi
  fi

  PHP_ADD_INCLUDE($PDO_GOLDILOCKS_INCDIR)
  PHP_ADD_LIBRARY_WITH_PATH($PDO_GOLDILOCKS_LIB, $PDO_GOLDILOCKS_LIBDIR, PDO_GOLDILOCKS_SHARED_LIBADD)

  ifdef([PHP_CHECK_PDO_INCLUDES],
  [
    PHP_CHECK_PDO_INCLUDES
  ],[
    AC_MSG_CHECKING([for PDO includes])
    if test -f $abs_srcdir/include/php/ext/pdo/php_pdo_driver.h; then
      pdo_cv_inc_path=$abs_srcdir/ext
    elif test -f $abs_srcdir/ext/pdo/php_pdo_driver.h; then
      pdo_cv_inc_path=$abs_srcdir/ext
    elif test -f $prefix/include/php/ext/pdo/php_pdo_driver.h; then
      pdo_cv_inc_path=$prefix/include/php/ext
    else
      AC_MSG_ERROR([Cannot find php_pdo_driver.h.])
    fi
    AC_MSG_RESULT($pdo_cv_inc_path)
  ])

  if test "$PHP_MAJOR_VERSION" = "7"; then
    PHP_NEW_EXTENSION(pdo_goldilocks, pdo_goldilocks.c goldilocks_driver7.c goldilocks_stmt7.c, $ext_shared,,-I$pdo_cv_inc_path)
  else
    PHP_NEW_EXTENSION(pdo_goldilocks, pdo_goldilocks.c goldilocks_driver.c goldilocks_stmt.c, $ext_shared,,-I$pdo_cv_inc_path)
  fi

  AC_DEFINE(HAVE_PDO_GOLDILOCKS,1,[ ])
  PHP_SUBST(PDO_GOLDILOCKS_SHARED_LIBADD)

  ifdef([PHP_ADD_EXTENSION_DEP],
  [
    PHP_ADD_EXTENSION_DEP(pdo_goldilocks, pdo)
  ])

fi


  
