--######################################################################################
-- View For Session Wait Event
--
-- MEMBER_NAME    : Cluster Member Name
-- ID             : Session Identifier
-- SERIAL         : Session Serial
-- PROGRAM        : Program Name
-- WAIT_ID        : Wait Event Identifier
-- WAIT_NAME      : Wait Event Name
-- WAIT_DESC      : Wait Event Description
-- TOTAL_WAITS    : Wait Count of Wait Event
-- TOTAL_TIMEOUTS : TimeOut Count of Wait Event
-- TIME_WAITED    : Total Wait Time For Wait Event ( Micro Seconds )
-- AVERAGE_WAIT   : TIME_WAITED / TOTAL_WAITS ( Micro Seconds )
-- MAX_WAIT       : Maximum Wait Time By Wait Event ( Micro Seconds )
-- CLASS_NAME     : Class Name
-- CLASS_DESC     : Class Description
--
--gSQL> SELECT * FROM TECH_SESSION_WAIT_EVENT@LOCAL;
--
--MEMBER_NAME ID SERIAL PROGRAM WAIT_ID WAIT_NAME                          WAIT_DESC                                            TOTAL_WAITS TOTAL_TIMEOUT TIME_WAITED AVERAGE_WAIT MAX_WAIT CLASS_NAME  CLASS_DESC                                        
------------- -- ------ ------- ------- ---------------------------------- ---------------------------------------------------- ----------- ------------- ----------- ------------ -------- ----------- --------------------------------------------------
--G1N1        53    745 gsql         10 ENQUEUE: CLUSTER REQUEST           Waiting for enqueue cluster request.                         260             0        1334            5      282 OTHER       Waits which should not typically occur on a system
--G1N1        53    745 gsql         11 ENQUEUE: CLUSTER BROADCAST REQUEST Waiting for enqueue cluster broadcast request.                48             0         224            4        9 OTHER       Waits which should not typically occur on a system
--G1N1        53    745 gsql         12 DEQUEUE: CLUSTER RESPONSE          Waiting for dequeue cluster request.                         401           401      253041          631    24407 OTHER       Waits which should not typically occur on a system
--G1N1        53    745 gsql         34 WAIT ENABLE LOGGING                Waiting for a logging available.                            3438             0         210            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         38 LATCH: LOG BUFFER                  Waiting for the log buffer latch.                           3437             0         331            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         40 LATCH: ENV MGR                     Waiting for the environment manager latch.                    41             0           3            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         42 LATCH: PCH                         Waiting for the page control Header latch.                 12847             0        1407            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         45 LATCH: ALLOC TRANS                 Waiting for the allocate transaction latch.                    3             0           1            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         46 LATCH: UNDO SEGMENT                Waiting for the undo segment latch.                            3             0           1            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         48 LATCH: DICT HASH ELEMENT AGING     Waiting for the dictionary hash element aging latch.         504             0          79            0        3 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         51 LATCH: TRACE LOG                   Waiting for the trace log latch.                              24             0           8            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         54 LATCH: SQL HANDLE                  Waiting for the SQL Handle latch.                             57             0          53            0        2 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         56 LATCH: PLAN CLOCK                  Waiting for the plan clock latch.                              7             0           0            0        0 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         59 LATCH: DYNAMIC MEM                 Waiting for the dynamic memory latch.                       4738             0         622            0        3 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         60 LATCH: PROPERTY                    Waiting for the property latch.                              231             0          15            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         70 LATCH: RECORD HASH                 Waiting for the record hash latch.                           362             0         142            0        9 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         72 LATCH: SEQUENCE                    Waiting for the sequence latch.                              140             0           7            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         73 LATCH: LOG STREAM                  Waiting for the log stream latch.                              2             0           0            0        0 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         74 LATCH: BUILD AGABLE SCN            Waiting for the build agable SCN latch.                        1             0           0            0        0 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         75 LATCH: TRANSACTION TABLE           Waiting for the transaction table latch.                       5             0           1            0        1 CONCURRENCY Waits for internal database resources             
--G1N1        53    745 gsql         79 LATCH: SEQUENCE GLOBALY            Waiting for the sequence global latch Y.                     140             0          23            0        1 CONCURRENCY Waits for internal database resources             
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_SESSION_WAIT_EVENT;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_SESSION_WAIT_EVENT
(
  MEMBER_NAME,
  ID,
  SERIAL,
  PROGRAM,
  WAIT_ID,
  WAIT_NAME,
  WAIT_DESC,
  TOTAL_WAITS,
  TOTAL_TIMEOUT,
  TIME_WAITED,
  AVERAGE_WAIT,
  MAX_WAIT,
  CLASS_NAME,
  CLASS_DESC
)
AS
SELECT
  NVL(XSE.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
  XS.ID ID,
  XS.SERIAL SERIAL,
  XS.PROGRAM PROGRAM,
  XWEN.WAIT_EVENT_ID WAIT_ID,
  XWEN.NAME WAIT_NAME,
  XWEN.DESCRIPTION WAIT_DESC,
  XSE.TOTAL_WAITS TOTAL_WAITS,
  XSE.TOTAL_TIMEOUTS TOTAL_TIMEOUT,
  XSE.TIME_WAITED TIME_WAITED,
  XSE.AVERAGE_WAIT AVERAGE_WAIT,
  XSE.MAX_WAIT MAX_WAIT,
  XWECN.NAME CLASS_NAME,
  XWECN.DESCRIPTION CLASS_DESC
FROM
  X$SESSION_EVENT@GLOBAL[IGNORE_INACTIVE_MEMBER] XSE,
  X$SESSION@GLOBAL[IGNORE_INACTIVE_MEMBER] XS,
  X$WAIT_EVENT_CLASS_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] XWECN,
  X$WAIT_EVENT_NAME@GLOBAL[IGNORE_INACTIVE_MEMBER] XWEN
WHERE
  1 = 1 AND
  NVL(XSE.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XSE.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XWECN.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XSE.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XWEN.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XWECN.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XWEN.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XWECN.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XWEN.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  XSE.SESSION_ID = XS.ID AND
  XSE.WAIT_EVENT_ID = XWEN.WAIT_EVENT_ID AND
  XWEN.CLASS_ID = XWECN.CLASS_ID AND
  XS.TOP_LAYER != 12 AND
  XS.PROGRAM != 'cluster peer'
ORDER BY MEMBER_NAME, ID, WAIT_ID;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_SESSION_WAIT_EVENT TO PUBLIC;