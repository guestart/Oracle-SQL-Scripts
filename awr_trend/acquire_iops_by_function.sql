REM
REM     Script:        acquire_iops_by_function.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 22, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       We can get "TOTAL_IOPS" in last 1 hour (interval by each minute) from the metric_name "SMALL_READ_IOPS", "SMALL_WRITE_IOPS",
REM       "LARGE_READ_IOPS" and "LARGE_WRITE_IOPS" of the view "v$iofuncmetric_history" (and also get "TOTAL_IOPS" in last 1 minute
REM       from the same metric_name above of the view "v$iofuncmetric").
REM
REM       DESC v$iostat_function
REM        Name                                                              Null?    Type
REM        ----------------------------------------------------------------- -------- --------------------------------------------
REM        FUNCTION_ID                                                                NUMBER
REM        FUNCTION_NAME                                                              VARCHAR2(18)
REM        SMALL_READ_MEGABYTES                                                       NUMBER
REM        SMALL_WRITE_MEGABYTES                                                      NUMBER
REM        LARGE_READ_MEGABYTES                                                       NUMBER
REM        LARGE_WRITE_MEGABYTES                                                      NUMBER
REM        SMALL_READ_REQS                                                            NUMBER
REM        SMALL_WRITE_REQS                                                           NUMBER
REM        LARGE_READ_REQS                                                            NUMBER
REM        LARGE_WRITE_REQS                                                           NUMBER
REM        NUMBER_OF_WAITS                                                            NUMBER
REM        WAIT_TIME                                                                  NUMBER
REM
REM       SET PAGESIZE 30
REM
REM       COLUMN function_name FOR a18
REM
REM       SELECT function_id, function_name FROM v$iostat_function ORDER BY 1;
REM
REM       FUNCTION_ID FUNCTION_NAME
REM       ----------- ------------------------------------
REM                 0 RMAN
REM                 1 DBWR
REM                 2 LGWR
REM                 3 ARCH
REM                 4 XDB
REM                 5 Streams AQ
REM                 6 Data Pump
REM                 7 Recovery
REM                 8 Buffer Cache Reads
REM                 9 Direct Reads
REM                10 Direct Writes
REM                11 Smart Scan
REM                12 Archive Manager
REM                13 Others
REM
REM       14 rows selected.
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-IOSTAT_FUNCTION.html#GUID-9AC74E4D-469E-4994-8829-C566190EC80D
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-IOFUNCMETRIC.html#GUID-6B17B9E1-52C6-493D-A2A2-41048E13D3E8
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-IOFUNCMETRIC_HISTORY.html#GUID-5D7603EC-7676-4CF1-908F-D9661339D436
REM

-- I/O Requests per Second in Last 1 Minute.
-- Horizontal Axis Name: I/O Per Sec

SET FEEDBACK  off;
SET SQLFORMAT csv;

SET LINESIZE 200
SET PAGESIZE 20

COLUMN sample_time   FORMAT a11
COLUMN function_name FORMAT a18
COLUMN iops          FORMAT 999,999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') sample_time
     , function_name
     , ROUND((small_read_iops+small_write_iops+large_read_iops+large_write_iops), 3) iops
FROM v$iofuncmetric
ORDER BY DECODE (function_name, 'Buffer Cache Reads', 1
                              , 'Direct Reads'      , 2
                              , 'Direct Writes'     , 3
                              , 'DBWR'              , 4
                              , 'LGWR'              , 5
                              , 'ARCH'              , 6
                              , 'RMAN'              , 7
                              , 'Recovery'          , 8
                              , 'Data Pump'         , 9
                              , 'Streams AQ'        , 10
                              , 'XDB'               , 11
                              , 'Others'            , 12
                              , 'Archive Manager'   , 13
                              , 'Smart Scan'        , 14
                )
;

-- Converting rows to columns Based on I/O Requests per Second in Last 1 Minute.
-- Horizontal Axis Name: I/O Per Sec

SET FEEDBACK  off;
SET SQLFORMAT csv;

SET LINESIZE 200
SET PAGESIZE 10

COLUMN sample_time   FORMAT a11
COLUMN function_name FORMAT a18
COLUMN iops          FORMAT 999,999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ifm AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') sample_time
       , function_name
       , ROUND((small_read_iops+small_write_iops+large_read_iops+large_write_iops), 3) iops
  FROM v$iofuncmetric
)
SELECT * FROM ifm
PIVOT ( MAX(iops)
        FOR function_name IN
        (  'Buffer Cache Reads' AS "Buffer Cache Reads"
         , 'Direct Reads'       AS "Direct Reads"
         , 'Direct Writes'      AS "Direct Writes"
         , 'DBWR'               AS "DBWR"
         , 'LGWR'               AS "LGWR"
         , 'ARCH'               AS "ARCH"
         , 'RMAN'               AS "RMAN"
         , 'Recovery'           AS "Recovery"
         , 'Data Pump'          AS "Data Pump"
         , 'Streams AQ'         AS "Streams AQ"
         , 'XDB'                AS "XDB"
         , 'Others'             AS "Others"
         , 'Archive Manager'    AS "Archive Manager"
         , 'Smart Scan'         AS "Smart Scan"
        )
      )
ORDER BY sample_time
;

================================================================================================================================

-- I/O Requests per Second in Last 1 Hour (interval by each minute).
-- Horizontal Axis Name: I/O Per Sec

SET FEEDBACK  off;
SET SQLFORMAT csv;

SET LINESIZE 200
SET PAGESIZE 900

COLUMN sample_time   FORMAT a11
COLUMN function_name FORMAT a18
COLUMN iops          FORMAT 999,999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') sample_time
     , function_name
     , ROUND((small_read_iops+small_write_iops+large_read_iops+large_write_iops), 3) iops
FROM v$iofuncmetric_history
ORDER BY DECODE (function_name, 'Buffer Cache Reads', 1
                              , 'Direct Reads'      , 2
                              , 'Direct Writes'     , 3
                              , 'DBWR'              , 4
                              , 'LGWR'              , 5
                              , 'ARCH'              , 6
                              , 'RMAN'              , 7
                              , 'Recovery'          , 8
                              , 'Data Pump'         , 9
                              , 'Streams AQ'        , 10
                              , 'XDB'               , 11
                              , 'Others'            , 12
                              , 'Archive Manager'   , 13
                              , 'Smart Scan'        , 14
                )
;

-- Converting rows to columns Based on I/O Requests per Second in Last 1 Hour (interval by each minute).
-- Horizontal Axis Name: I/O Per Sec

SET FEEDBACK  off;
SET SQLFORMAT csv;

SET LINESIZE 200
SET PAGESIZE 80

COLUMN sample_time   FORMAT a11
COLUMN function_name FORMAT a18
COLUMN iops          FORMAT 999,999,999.999

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH ifmh AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') sample_time
       , function_name
       , ROUND((small_read_iops+small_write_iops+large_read_iops+large_write_iops), 3) iops
  FROM v$iofuncmetric_history
)
SELECT * FROM ifmh
PIVOT ( MAX(iops)
        FOR function_name IN
        (  'Buffer Cache Reads' AS "Buffer Cache Reads"
         , 'Direct Reads'       AS "Direct Reads"
         , 'Direct Writes'      AS "Direct Writes"
         , 'DBWR'               AS "DBWR"
         , 'LGWR'               AS "LGWR"
         , 'ARCH'               AS "ARCH"
         , 'RMAN'               AS "RMAN"
         , 'Recovery'           AS "Recovery"
         , 'Data Pump'          AS "Data Pump"
         , 'Streams AQ'         AS "Streams AQ"
         , 'XDB'                AS "XDB"
         , 'Others'             AS "Others"
         , 'Archive Manager'    AS "Archive Manager"
         , 'Smart Scan'         AS "Smart Scan"
        )
      )
ORDER BY sample_time
;
