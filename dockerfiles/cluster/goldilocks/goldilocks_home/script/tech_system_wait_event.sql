--######################################################################################
-- View For System Wait Event
--
-- MEMBER_NAME    : Cluster Member Name
-- WAIT_ID        : Wait Event Identifier
-- WAIT_NAME      : Wait Event Name
-- WAIT_DESC      : Wait Event Description
-- TOTAL_WAITS    : Wait Count of Wait Event
-- TOTAL_TIMEOUTS : TimeOut Count of Wait Event
-- TIME_WAITED    : Total Wait Time For Wait Event ( Micro Seconds )
-- AVERAGE_WAIT   : TIME_WAITED / TOTAL_WAITS ( Micro Seconds )
-- CLASS_NAME     : Class Name
-- CLASS_DESC     : Class Description
--
--gSQL> SELECT * FROM TECH_SYSTEM_WAIT_EVENT@LOCAL;
--
--MEMBER_NAME WAIT_ID WAIT_NAME                              WAIT_DESC                                                           TOTAL_WAITS TOTAL_TIMEOUTS TIME_WAITED AVERAGE_WAIT CLASS_NAME  CLASS_DESC                                        
------------- ------- -------------------------------------- ------------------------------------------------------------------- ----------- -------------- ----------- ------------ ----------- --------------------------------------------------
--G1N1              1 ENQUEUE: GDISPATCHER REQUEST           GDISPATCHER waits for enqueue request to shared server.                       0              0           0            0 OTHER       Waits which should not typically occur on a system
--G1N1              2 ENQUEUE: SHARED SERVER RESPONSE        Shared server waits for enqueue response to GDISPATCHER.                      0              0           0            0 OTHER       Waits which should not typically occur on a system
--G1N1              3 DEQUEUE: SHARED SERVER REQUEST         Shared server waits for dequeue request from GDISPATCHER.                     0              0           0            0 OTHER       Waits which should not typically occur on a system
--G1N1              4 DEQUEUE: GDISPATCHER RESPONSE          GDISPATCHER waits for dequeue response from shared server.                    0              0           0            0 OTHER       Waits which should not typically occur on a system
--G1N1              5 SEND: DEDICATE SERVER SPOOLED RESPONSE Dedicate server is sending a spooled response message to the client           0              0           0            0 NETWORK     Waits related to network messaging                
--G1N1              6 SEND: DEDICATE SERVER RESPONSE         Dedicate server is sending a response message to the client                   0              0           0            0 NETWORK     Waits related to network messaging                
--G1N1              7 RECV: DEDICATE SERVER REQUEST          Dedicate server is receiving a request message from the client.               0              0           0            0 NETWORK     Waits related to network messaging                
--G1N1              8 SEND: GDISPATCHER RESPONSE             GDISPATCHER is sending a response message to the client.                      0              0           0            0 NETWORK     Waits related to network messaging                
--G1N1              9 RECV: GDISPATCHER REQUEST              GDISPATCHER is receiving a request message from the client.                   0              0           0            0 NETWORK     Waits related to network messaging                
--G1N1             10 ENQUEUE: CLUSTER REQUEST               Waiting for enqueue cluster request.                                     163841              0      707801            4 OTHER       Waits which should not typically occur on a system
--G1N1             11 ENQUEUE: CLUSTER BROADCAST REQUEST     Waiting for enqueue cluster broadcast request.                             3646              0       10479            2 OTHER       Waits which should not typically occur on a system
--G1N1             12 DEQUEUE: CLUSTER RESPONSE              Waiting for dequeue cluster request.                                      11121          11108    27045117         2431 OTHER       Waits which should not typically occur on a system
--G1N1             13 SEND: CDISPATCHER                      CDISPATCHER is sending a message.                                        171548              0     3964729           23 NETWORK     Waits related to network messaging                
--G1N1             14 RECV: CDISPATCHER                      CDISPATCHER is receiving a message.                                      171461              0     1185143            6 NETWORK     Waits related to network messaging                
--G1N1             15 GMASTER: ARCHIVE LOG                   GMASTER process waits for archive logs.                                       2              0     3624197      1812098 SYSTEM IO   Waits for background process IO                   
--G1N1             16 GMASTER: CHECKPOINT                    GMASTER process waits for checkpoint.                                         2              0    17528211      8764105 SYSTEM IO   Waits for background process IO                   
--G1N1             17 GMASTER: IO SLAVE                      GMASTER process waits for io slaves.                                          8              0    11751384      1468923 SYSTEM IO   Waits for background process IO                   
--G1N1             18 GMASTER: LOG FLUSH                     GMASTER process waits for log flush.                                        454              0     1486371         3273 SYSTEM IO   Waits for background process IO                   
--G1N1             19 GMASTER: PAGE FLUSH                    GMASTER process waits for page flush.                                         3              0     6982116      2327372 SYSTEM IO   Waits for background process IO                   
--G1N1             20 WRITE: TRACE LOG                       Waiting for the write to trace log.                                           0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             21 WRITE: COPY ARCHIVING LOG              Waiting for the copy to archiving log.                                        0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             22 WRITE: BACKUP CTRL FILE                Waiting for the backup to control file.                                       0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             23 WRITE: RESTORE CTRL FILE               Waiting for the restore to control file.                                      0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             24 READ: ARCHIVE LOG                      Waiting for the read from archive log.                                        0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             25 READ: CTRL FILE                        Waiting for the read from control file.                                    1146              0    21081464        18395 SYSTEM IO   Waits for background process IO                   
--G1N1             26 WRITE: LOG FILE                        Waiting for the write to log file.                                            0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             27 WRITE: PAGE FILE                       Waiting for the write to page file.                                          31              0     7342812       236864 SYSTEM IO   Waits for background process IO                   
--G1N1             28 WRITE: CTRL FILE                       Waiting for the write to control file.                                      192              0    13332504        69440 SYSTEM IO   Waits for background process IO                   
--G1N1             29 WRITE: REMOVE DATA FILE                Waiting for the remove to data file.                                          0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             30 WRITE: JOURNAL BUFFER                  Waiting for the write journal buffer.                                         0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             31 READ: JOURNAL BUFFER                   Waiting for the read journal buffer.                                          0              0           0            0 SYSTEM IO   Waits for background process IO                   
--G1N1             32 WAIT TRANSACTION                       Waiting for a transaction termination.                                        0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             33 WAIT OTHER TRANSACTION                 Waiting for a other transaction termination.                                  0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             34 WAIT ENABLE LOGGING                    Waiting for a logging available.                                           1904              0          96            0 CONCURRENCY Waits for internal database resources             
--G1N1             35 WAIT LOG FLUSHER                       Waiting for a log flusher available.                                         11              0       43068         3915 CONCURRENCY Waits for internal database resources             
--G1N1             36 WAIT PAGE FLUSHER                      Waiting for a page flusher available.                                         0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             37 WAIT XA CONTEXT                        Waiting for a XA context available.                                           0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             38 LATCH: LOG BUFFER                      Waiting for the log buffer latch.                                          1946              0         169            0 CONCURRENCY Waits for internal database resources             
--G1N1             39 LATCH: PROCESS MANAGER                 Waiting for the process manager latch.                                        7              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             40 LATCH: ENV MGR                         Waiting for the environment manager latch.                                13290              0           3            0 CONCURRENCY Waits for internal database resources             
--G1N1             41 LATCH: SESSION ENV MGR                 Waiting for the session environment manager latch.                         2310              0           1            0 CONCURRENCY Waits for internal database resources             
--G1N1             42 LATCH: PCH                             Waiting for the page control Header latch.                                47233              0        2574            0 CONCURRENCY Waits for internal database resources             
--G1N1             43 LATCH: PAGE                            Waiting for the page latch.                                                   5              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             44 LATCH: PENDING LOG                     Waiting for the pending log latch.                                            0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             45 LATCH: ALLOC TRANS                     Waiting for the allocate transaction latch.                                  10              0           3            0 CONCURRENCY Waits for internal database resources             
--G1N1             46 LATCH: UNDO SEGMENT                    Waiting for the undo segment latch.                                          10              0           1            0 CONCURRENCY Waits for internal database resources             
--G1N1             47 LATCH: CLUSTER LOCATION                Waiting for the cluster location latch.                                      34              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             48 LATCH: DICT HASH ELEMENT AGING         Waiting for the dictionary hash element aging latch.                      79770              0          54            0 CONCURRENCY Waits for internal database resources             
--G1N1             49 LATCH: DICT HASH RELATED AGING         Waiting for the dictionary hash related aging latch.                       6139              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             50 LATCH: FILE MANAGER                    Waiting for the file manager latch.                                          11              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             51 LATCH: TRACE LOG                       Waiting for the trace log latch.                                            260              0           4            0 CONCURRENCY Waits for internal database resources             
--G1N1             52 LATCH: STATIC HASH                     Waiting for the static hash latch.                                            0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             53 LATCH: STATIC HASH BUCKET              Waiting for the static hash bucket latch.                                     0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             54 LATCH: SQL HANDLE                      Waiting for the SQL Handle latch.                                         25640              0       20089            0 CONCURRENCY Waits for internal database resources             
--G1N1             55 LATCH: XA CONTEXT HASH                 Waiting for the XA context hash latch.                                        0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             56 LATCH: PLAN CLOCK                      Waiting for the plan clock latch.                                            80              0           3            0 CONCURRENCY Waits for internal database resources             
--G1N1             57 LATCH: XA CONTEXT                      Waiting for the XA context latch.                                             0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             58 LATCH: MEM CONTROLLER                  Waiting for the memory controller latch.                                      2              0           1            0 CONCURRENCY Waits for internal database resources             
--G1N1             59 LATCH: DYNAMIC MEM                     Waiting for the dynamic memory latch.                                    766321              0       70724            0 CONCURRENCY Waits for internal database resources             
--G1N1             60 LATCH: PROPERTY                        Waiting for the property latch.                                          532637              0       20022            0 CONCURRENCY Waits for internal database resources             
--G1N1             61 LATCH: ATTACH SHM                      Waiting for the attach shared memory latch.                                  25              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             62 LATCH: BACKUP TBS                      Waiting for the backup tablespace latch.                                     16              0           2            0 CONCURRENCY Waits for internal database resources             
--G1N1             63 LATCH: DATABASE COMPONENT              Waiting for the database component latch.                                    19              0           1            0 CONCURRENCY Waits for internal database resources             
--G1N1             64 LATCH: TABLESPACE                      Waiting for the tablespace latch.                                             0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             65 LATCH: BACKUP DATABASE                 Waiting for the backup database latch.                                        0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             66 LATCH: JOURNAL BUFFER                  Waiting for the journal buffer latch.                                         0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             67 LATCH: JOURNAL BUFFER ENTRY            Waiting for the journal buffer entry latch.                                   0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             68 LATCH: JOURNAL WRITE BUFFER            Waiting for the journal write buffer latch.                                   0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             69 LATCH: LOCK ITEM                       Waiting for the lock item latch.                                             18              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             70 LATCH: RECORD HASH                     Waiting for the record hash latch.                                          452              0         226            0 CONCURRENCY Waits for internal database resources             
--G1N1             71 LATCH: DEADLOCK                        Waiting for the deadlock latch.                                               0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             72 LATCH: SEQUENCE                        Waiting for the sequence latch.                                             104              0           8            0 CONCURRENCY Waits for internal database resources             
--G1N1             73 LATCH: LOG STREAM                      Waiting for the log stream latch.                                            60              0      625526        10425 CONCURRENCY Waits for internal database resources             
--G1N1             74 LATCH: BUILD AGABLE SCN                Waiting for the build agable SCN latch.                                13317588              0     6111532            0 CONCURRENCY Waits for internal database resources             
--G1N1             75 LATCH: TRANSACTION TABLE               Waiting for the transaction table latch.                                  59080              0        8636            0 CONCURRENCY Waits for internal database resources             
--G1N1             76 LATCH: SESSION LINK HASH               Waiting for the session link hash latch.                                    212              0         502            2 CONCURRENCY Waits for internal database resources             
--G1N1             77 LATCH: ALLOC XA CONTEXT                Waiting for the allocate XA context latch.                                    0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             78 LATCH: SEQUENCE GLOBALX                Waiting for the sequence global latch X.                                      0              0           0            0 CONCURRENCY Waits for internal database resources             
--G1N1             79 LATCH: SEQUENCE GLOBALY                Waiting for the sequence global latch Y.                                    104              0          13            0 CONCURRENCY Waits for internal database resources             
--G1N1             80 LATCH: TRANSACTION LOG FILE            Waiting for the transaction log file latch.                                  32              0           1            0 CONCURRENCY Waits for internal database resources             
--G1N1             81 ASYNC RESPONSE                         Waiting for asynchronous response from remote member.                         1              0           0            0 OTHER       Waits which should not typically occur on a system
--G1N1             82 ASYNC TRANSACTION                      Waiting for commit response of asynchronous transaction.                      0              0           0            0 OTHER       Waits which should not typically occur on a system
--G1N1             83 ASYNC COMMIT                           Waiting for commit completion                                                 0              0           0            0 OTHER       Waits which should not typically occur on a system
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_SYSTEM_WAIT_EVENT;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_SYSTEM_WAIT_EVENT
(
  MEMBER_NAME,
  WAIT_ID,
  WAIT_NAME,
  WAIT_DESC,
  TOTAL_WAITS,
  TOTAL_TIMEOUTS,
  TIME_WAITED,
  AVERAGE_WAIT,
  CLASS_NAME,
  CLASS_DESC
)
AS
SELECT
  NVL(XWECN.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
  XWEN.WAIT_EVENT_ID WAIT_ID,
  XWEN.NAME WAIT_NAME,
  XWEN.DESCRIPTION WAIT_DESC,
  NVL(XSE.TOTAL_WAITS, 0) TOTAL_WAITS,
  NVL(XSE.TOTAL_TIMEOUTS, 0) TOTAL_TIMEOUTS,
  NVL(XSE.TIME_WAITED, 0) TIME_WAITED,
  NVL(XSE.AVERAGE_WAIT, 0) AVERAGE_WAIT,
  XWECN.NAME CLASS_NAME,
  XWECN.DESCRIPTION CLASS_DESC
FROM
  X$WAIT_EVENT_CLASS_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] XWECN,
  X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] XWEN
  LEFT OUTER JOIN
  ( SELECT
      NVL(XSE.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
	  XSE.WAIT_EVENT_ID WAIT_EVENT_ID,
	  XSE.TOTAL_WAITS TOTAL_WAITS,
	  XSE.TOTAL_TIMEOUTS TOTAL_TIMEOUTS,
	  XSE.TIME_WAITED TIME_WAITED,
	  XSE.AVERAGE_WAIT AVERAGE_WAIT
	FROM
	  X$SYSTEM_EVENT@GLOBAL[IGNORE_INACTIVE_MEMBER] XSE ) XSE
	ON
	  1 = 1 AND
	  XWEN.WAIT_EVENT_ID = XSE.WAIT_EVENT_ID AND
	  NVL(XWEN.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XSE.MEMBER_NAME, 'STANDALONE')
WHERE
  1 = 1 AND
  NVL(XWECN.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XWEN.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  XWEN.CLASS_ID = XWECN.CLASS_ID
ORDER BY MEMBER_NAME, WAIT_ID;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_SYSTEM_WAIT_EVENT TO PUBLIC;