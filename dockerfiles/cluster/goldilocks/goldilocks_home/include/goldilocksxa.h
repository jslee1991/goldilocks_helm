#ifndef _GOLDILOCKSXA_H_
#define _GOLDILOCKSXA_H_ 1

#ifdef __cplusplus
extern "C" {
#endif

extern xa_switch_t goldilocks_xa_switch;

xa_switch_t* SQLGetXaSwitch();
SQLHANDLE    SQLGetXaConnectionHandle(int *rm_id);

#ifdef __cplusplus
}
#endif

#endif
