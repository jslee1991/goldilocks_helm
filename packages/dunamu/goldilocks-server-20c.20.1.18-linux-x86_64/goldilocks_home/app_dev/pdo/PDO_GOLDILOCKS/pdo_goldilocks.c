#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "php.h"
#include "php_ini.h"
#include "ext/standard/info.h"
#include "pdo/php_pdo.h"
#include "pdo/php_pdo_driver.h"
#include "php_pdo_goldilocks.h"
#include "php_pdo_goldilocks_int.h"

const zend_function_entry pdo_goldilocks_functions[] =
{
#if defined(PHP_FE_END)
    PHP_FE_END
#else
    {NULL, NULL, NULL}
#endif
};

#if ZEND_MODULE_API_NO >= 20050922
static const zend_module_dep pdo_goldilocks_deps[] =
{
    ZEND_MOD_REQUIRED("pdo")
#if defined(ZEND_MOD_END)
    ZEND_MOD_END
#else
    {NULL, NULL, NULL}
#endif
};
#endif

zend_module_entry pdo_goldilocks_module_entry =
{
#if ZEND_MODULE_API_NO >= 20050922
    STANDARD_MODULE_HEADER_EX, NULL,
    pdo_goldilocks_deps,
#else
    STANDARD_MODULE_HEADER,
#endif
    "pdo_goldilocks",
    pdo_goldilocks_functions,
    PHP_MINIT(pdo_goldilocks),
    PHP_MSHUTDOWN(pdo_goldilocks),
    NULL,
    NULL,
    PHP_MINFO(pdo_goldilocks),
    "20.1.18",
    STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_PDO_GOLDILOCKS
ZEND_GET_MODULE(pdo_goldilocks)
#endif

PHP_MINIT_FUNCTION(pdo_goldilocks)
{
    if( FAILURE == php_pdo_register_driver( &pdo_goldilocks_driver ) )
    {
        return FAILURE;
    }

    return SUCCESS;
}

PHP_MSHUTDOWN_FUNCTION(pdo_goldilocks)
{
    php_pdo_unregister_driver( &pdo_goldilocks_driver );
    
    return SUCCESS;
}

PHP_MINFO_FUNCTION(pdo_goldilocks)
{
    php_info_print_table_start();
    php_info_print_table_header( 2, "PDO Driver for GOLDILOCKS" , "enabled" );
    php_info_print_table_end();
}
