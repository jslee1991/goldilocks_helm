#ifndef PHP_PDO_GOLDILOCKS_INT_H
#define PHP_PDO_GOLDILOCKS_INT_H

#include <goldilocks.h>

typedef struct
{
    char         last_state[6];
    char         last_err_msg[SQL_MAX_MESSAGE_LENGTH];
    SQLINTEGER   last_error;
    const char * file;
    const char * what;
    int          line;
} pdo_goldilocks_errinfo;

typedef struct
{
    SQLHANDLE	           env;
    SQLHANDLE	           dbc;
    pdo_goldilocks_errinfo einfo;
} pdo_goldilocks_db_handle;

typedef struct
{
    char          * data;
    SQLULEN         datalen;
    SQLLEN          fetched_len;
    SQLSMALLINT     coltype;
    char            colname[128];
} pdo_goldilocks_column;

typedef struct
{
    SQLHANDLE	               stmt;
    pdo_goldilocks_column    * cols;
    pdo_goldilocks_db_handle * H;
    pdo_goldilocks_errinfo     einfo;
} pdo_goldilocks_stmt;

typedef struct
{
    LONG_VARIABLE_LENGTH_STRUCT   strbuf;
    char                        * outbuf;
    SQLLEN                        len;
    SQLSMALLINT                   paramtype;
} pdo_goldilocks_param;
	
extern pdo_driver_t pdo_goldilocks_driver;
extern struct pdo_stmt_methods goldilocks_stmt_methods;

void pdo_goldilocks_error(pdo_dbh_t *dbh, pdo_stmt_t *stmt, SQLHANDLE statement, char *what, const char *file, int line TSRMLS_DC);
#define pdo_goldilocks_drv_error(what)	pdo_goldilocks_error(dbh, NULL, SQL_NULL_HSTMT, what, __FILE__, __LINE__ TSRMLS_CC)
#define pdo_goldilocks_stmt_error(what)	pdo_goldilocks_error(stmt->dbh, stmt, SQL_NULL_HSTMT, what, __FILE__, __LINE__ TSRMLS_CC)
#define pdo_goldilocks_doer_error(what)	pdo_goldilocks_error(dbh, NULL, stmt, what, __FILE__, __LINE__ TSRMLS_CC)

void pdo_goldilocks_init_error_table(void);
void pdo_goldilocks_fini_error_table(void);

#endif /* PHP_PDO_GOLDILOCKS_INT_H */
