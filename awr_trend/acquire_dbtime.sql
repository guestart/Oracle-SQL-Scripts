REM
REM     Script:        acquire_dbtime.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 18, 2021
REM
REM     Updated:       Sep 22, 2021
REM                    (1) Adding the content of Purpose;
REM                    (2) Rewritten SQL script to the format "WITH ... AS ()" so that more clearly reading and understanding;
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       We can acquire "DB time" from the AWR report that locates between the begin snapshot and end one,
REM       if we wanna look at the "DB time" all of the AWR reports it's unnecessary to generate one by one.
REM       Hence it's the reason why I wrote this SQL Script.
REM
REM       You know, there saves the value of "DB time" in each of snap_id of the view DBA_HIST_SYS_TIME_MODEL
REM       but which is from the oracle instance starts up to that snap_id, here we have to use the analytic
REM       function "LAG () OVER()" to get the prior value of prior snap_id then current vlaue of current snap_id
REM       subtracts the prior one we can get the real "DB time" between these two snap_id.
REM
REM       In addition to the begin_interval_time and end_interval_time are in the view DBA_HIST_SNAPSHOT we are
REM       able to (inner) join the view DBA_HIST_SNAPSHOT and DBA_HIST_SYS_TIME_MODEL in order to get begin_time
REM       and end_time of a snap_id.
REM
REM       SET LINESIZE 80
REM       DESC acquire_awr_dbtime
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        STAT_NAME                                 NOT NULL VARCHAR2(10)
REM        AWR_ DBTIME_MINS                                   NUMBER
REM
REM     Reference:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SNAPSHOT.html#GUID-542B6CA6-793B-4D15-AAFD-4D3E6550C0B6
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYS_TIME_MODEL.html#GUID-263D0396-7C98-4C26-9993-DCC42EA9E87E
REM       http://blog.itpub.net/28602568/viewspace-1467897/
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN begin_time      FORMAT a19
COLUMN end_time        FORMAT a19
COLUMN stat_name       FORMAT a10
COLUMN awr_dbtime_mins FORMAT 999,999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH
dhsp AS (
          SELECT snap_id
               , dbid
               , instance_number
               , begin_interval_time
               , end_interval_time
          FROM dba_hist_snapshot
        ),
dhstm AS (
           SELECT snap_id
                , dbid
                , instance_number
                , stat_name
                , value
           FROM dba_hist_sys_time_model
           WHERE stat_name = 'DB time'
         ),
all_awr_dbtime AS (
                    SELECT dhsp.instance_number
                         , LAG(dhsp.snap_id, 1, 0) OVER (PARTITION BY dhsp.dbid, dhsp.instance_number ORDER BY dhsp.snap_id) first_snap_id
                         , dhsp.snap_id second_snap_id
                      -- , TO_CHAR(dhsp.begin_interval_time, 'yyyy-mm-dd hh24:mi:ss') begin_time
                      -- , TO_CHAR(dhsp.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') end_time
                         , CAST(dhsp.begin_interval_time AS DATE) begin_time
                         , CAST(dhsp.end_interval_time AS DATE) end_time
                         , dhstm.stat_name
                         , ROUND((dhstm.value - LAG(dhstm.value, 1, 0) OVER (PARTITION BY dhstm.dbid, dhstm.instance_number ORDER BY dhstm.snap_id))/1e6/6e1, 2) awr_dbtime_mins
                    FROM dhsp
                       , dhstm
                    WHERE dhsp.snap_id = dhstm.snap_id
                    AND   dhsp.instance_number = dhstm.instance_number
                    AND   dhsp.dbid = dhstm.dbid
                 -- AND   dhstm.stat_name = 'DB time'
                    ORDER BY dhsp.instance_number
                           , first_snap_id
                  )
SELECT *
FROM all_awr_dbtime
WHERE first_snap_id <> 0
;
