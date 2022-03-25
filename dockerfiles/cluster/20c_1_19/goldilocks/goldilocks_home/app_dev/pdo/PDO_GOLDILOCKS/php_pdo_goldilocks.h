#ifndef PHP_PDO_GOLDILOCKS_H
#define PHP_PDO_GOLDILOCKS_H

extern zend_module_entry pdo_goldilocks_module_entry;
#define phpext_pdo_goldilocks_ptr &pdo_goldilocks_module_entry

#ifdef ZTS
#include "TSRM.h"
#endif

PHP_MINIT_FUNCTION(pdo_goldilocks);
PHP_MSHUTDOWN_FUNCTION(pdo_goldilocks);
PHP_RINIT_FUNCTION(pdo_goldilocks);
PHP_RSHUTDOWN_FUNCTION(pdo_goldilocks);
PHP_MINFO_FUNCTION(pdo_goldilocks);

/* 
   Declare any global variables you may need between the BEGIN
   and END macros here:     

   ZEND_BEGIN_MODULE_GLOBALS(pdo_goldilocks)
   long  global_value;
   char *global_string;
   ZEND_END_MODULE_GLOBALS(pdo_goldilocks)
*/

/* In every utility function you add that needs to use variables 
   in php_pdo_goldilocks_globals, call TSRMLS_FETCH(); after declaring other 
   variables used by that function, or better yet, pass in TSRMLS_CC
   after the last function argument and declare your utility function
   with TSRMLS_DC after the last declared argument.  Always refer to
   the globals in your function as PDO_GOLDILOCKS_G(variable).  You are 
   encouraged to rename these macros something shorter, see
   examples in any other php module directory.
*/

#ifdef ZTS
#define PDO_GOLDILOCKS_G(v) TSRMG(pdo_goldilocks_globals_id, zend_pdo_goldilocks_globals *, v)
#else
#define PDO_GOLDILOCKS_G(v) (pdo_goldilocks_globals.v)
#endif

#endif	/* PHP_PDO_GOLDILOCKS_H */
