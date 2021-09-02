/*******************************************************************************
 * sqlca.h
 *
 * Copyright (c) 2011, SUNJESOFT Inc.
 *
 *
 * IDENTIFICATION & REVISION
 *        $Id$
 *
 * NOTES
 *   SQLCA : SQL Communications Area
 *
 ******************************************************************************/

#ifndef _SQLCA_H_
#define _SQLCA_H_ 1

/**
 * @file sqlca.h
 * @brief SQLCA structure for Embedded SQL.
 */

/* SQLERRMC_LEN은 8의 배수 - 2(short의 크기)로 정한다. */
#define SQLERRMC_LEN	518

#ifndef sqlca
#define sqlca gsqlca
#endif

typedef struct sqlca sqlca_t;
struct sqlca
{
    char    sqlcaid[8];   /* 문자열 SQLCA 로 초기화 */
    int     sqlabc;       /* sqlca 구조체의 크기   */

    /*
     * 가장 최근의 문장 실행에서 발생한 error code
     * 0이면 성공. 양수이면 Warning, 음수이면 Error
     */
    int     sqlcode;

    /*
     * sqlcode에 해당하는 에러 메세지를 저장
     *  .sqlerrml은 sqlerrmc의 길이
     *  .sqlerrmc는 에러 메세지를 string 형태로 저장
     */
    struct
    {
        unsigned short sqlerrml;
        char           sqlerrmc[SQLERRMC_LEN];
    } sqlerrm;

    char    sqlerrp[8];   /* unused                         */
    int     sqlerrd[6];
    /* 0: empty                                             */
    /* 1: empty                                             */
    /* 2: INSERT, UPDATE, DELETE 후에 처리된 row의 개수         */
    /* 3: empty                                             */
    /* 4: empty                                             */
    /* 5: empty                                             */
    char    sqlwarn[8];
    /* 0: 임의의 Warning이 1개라도 발생할 경우 'W'
     * 1: SELECT, FETCH에서 결과 String이 truncate 된 경우 'W'
     * 2: unused
     * 3: unused
     * 4: unused
     * 5: unused
     * 6: unused
     * 7: unused
     */
    char    sqlext[8];    /* unused                         */
    char    sqlstate[8];  /* SQLSTATE                       */

    unsigned short  *rowstatus;    /* fetched row status array*/
};

#ifndef SQLCA_NONE
#ifdef   SQLCA_STORAGE_CLASS
SQLCA_STORAGE_CLASS sqlca_t sqlca;
#else
sqlca_t sqlca;
#endif
#endif

//char    SQLSTATE[6];
#define SQLSTATE         (sqlca.sqlstate)
#define SQLCODE          (sqlca.sqlcode)


#endif /* _SQLCA_H_ */
