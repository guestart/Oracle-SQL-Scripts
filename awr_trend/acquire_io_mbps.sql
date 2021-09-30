REM
REM     Script:        acquire_io_mbps.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Sep 23, 2021
REM
REM     Updated:       Sep 24, 2021
REM       Searched out the MoS article "How to Calculate the Number of IOPS and Throughput of a Database (Doc ID 2206831.1)" from Google,
REM       it told us IOPS can be found in different places of the AWR report:
REM         (1) Instance Activity Stats
REM         (2) IO Profile (Starting with 11gR2)
REM         (3) Load Profile
REM
REM       Instance Activity Stats:
REM       Throughput - This is the sum of "Physical read total bytes" and "Physical write total bytes".
REM
REM       IO Profile:
REM       Throughput in Mbps - Total (MB) (This value is the sum of the metrics "Physical read total bytes/sec" and "Physical write total bytes/sec" from the AWR report).
REM
REM       Load Profile:
REM       Please note that the information displayed here is a subset of the one in the IO Profile area:
REM
REM       Load profile      -> Instance Activity Stats
REM       Read IO (MB)      -> physical read bytes
REM       Write IO (MB)     -> physical write bytes
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM  -- Purpose:
REM  --   Typically there saves the value of "physical read bytes" and "physical write bytes" in each
REM  --   of snap_id of the view "DBA_HIST_SYSSTAT" (adding them can get the value of "IO Mbytes") but
REM  --   which is from the oracle instance starts up to that snap_id, here we have to use the analytic
REM  --   function "LAG () OVER()" to get the prior value of prior snap_id then current vlaue of current
REM  --   snap_id subtracts the prior one we can get the real "IO Mbytes" between these two snap_id,
REM  --   then "IO Mbytes" divides by the spending time (calculate it by seconds) between the prior
REM  --   snap_id and the current snap_id. Ultimately we can get the "IO Mbps".
REM  -- 
REM  --   In addition to the begin_interval_time and end_interval_time are in the view DBA_HIST_SNAPSHOT
REM  --   we're able to (inner) join the view DBA_HIST_SNAPSHOT and DBA_HIST_SYSSTAT in order to get
REM  --   begin_time and end_time of a snap_id.
REM  -- 
REM  -- References:
REM  --   https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSSTAT.html#GUID-C94C6E6D-3FB0-4A81-A350-A1F312CDFEBB
REM  --   https://blog.csdn.net/qq_40687433/article/details/79467984
REM
REM     Purpose:
REM       Typically there saves the average value of "Physical Read Total Bytes Per Sec" and "Physical Write Total Bytes Per Sec"
REM       in each of snap_id of the view "DBA_HIST_SYSMETRIC_SUMMARY" (in which the value of its column "metric_unit" is
REM       "Physical Read Total Bytes Per Sec" and "Physical Write Total Bytes Per Sec"), here we use the analytic function
REM       "LAG () OVER()" to get the prior snap_id from current snap_id for more clearly showing "IOPS" between these two snap_id.
REM
REM       SET LINESIZE 80
REM       DESC acquire_awr_io_mbps
REM        Name                                      Null?    Type
REM        ----------------------------------------- -------- ----------------------------
REM        INSTANCE_NUMBER                           NOT NULL NUMBER
REM        FIRST_SNAP_ID                             NOT NULL NUMBER
REM        SECOND_SNAP_ID                            NOT NULL NUMBER
REM        BEGIN_TIME                                NOT NULL DATE
REM        END_TIME                                  NOT NULL DATE
REM        METRIC_NAME                               NOT NULL VARCHAR2(40)
REM        METRIC_UNIT                               NOT NULL VARCHAR2(16)
REM        AWR_IO_MBPS                                        NUMBER
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM

SET LINESIZE 200
SET PAGESIZE 200

COLUMN metric_name FORMAT a40
COLUMN metric_unit FORMAT a16
COLUMN awr_io_mbps FORMAT 999,999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

-- WITH
-- dhsp AS (
--           SELECT snap_id
--                , dbid
--                , instance_number
--                , begin_interval_time
--                , end_interval_time
--           FROM dba_hist_snapshot
--         ),
-- dhst AS ( 
--           SELECT snap_id
--                , dbid
--                , instance_number
--                , SUM(value) value
--           FROM dba_hist_sysstat
--           WHERE stat_name IN ('physical read bytes', 'physical write bytes')
--           GROUP BY snap_id
--                  , dbid
--                  , instance_number
--         ),
-- all_awr_io_mbps AS (
--                      SELECT dhsp.instance_number
--                           , LAG(dhsp.snap_id, 1, 0) OVER (PARTITION BY dhsp.dbid, dhsp.instance_number ORDER BY dhsp.snap_id) first_snap_id
--                           , dhsp.snap_id second_snap_id
--                        -- , TO_CHAR(dhsp.begin_interval_time, 'yyyy-mm-dd hh24:mi:ss') begin_time
--                        -- , TO_CHAR(dhsp.end_interval_time, 'yyyy-mm-dd hh24:mi:ss') end_time
--                           , CAST(dhsp.begin_interval_time AS DATE) begin_time
--                           , CAST(dhsp.end_interval_time AS DATE) end_time
--                           , (dhst.value - LAG(dhst.value, 1, 0) OVER (PARTITION BY dhst.dbid, dhst.instance_number ORDER BY dhst.snap_id)) / POWER(2, 20) io_mb_size
--                           , (CAST(dhsp.end_interval_time AS DATE) - CAST(dhsp.begin_interval_time AS DATE))*24*36e2 interval_seconds
--                      FROM dhsp
--                         , dhst
--                      WHERE dhsp.snap_id = dhst.snap_id
--                      AND   dhsp.instance_number = dhst.instance_number
--                      AND   dhsp.dbid = dhst.dbid
--                      ORDER BY dhsp.snap_id
--                    )
-- SELECT instance_number
--      , first_snap_id
--      , second_snap_id
--      , begin_time
--      , end_time
--      , ROUND(io_mb_size / interval_seconds, 2) io_mbps
-- FROM all_awr_io_mbps
-- WHERE first_snap_id <> 0
-- ;

SELECT *
FROM (
       SELECT instance_number
            , LAG(snap_id, 1, 0) OVER(PARTITION BY dbid, instance_number ORDER BY snap_id) first_snap_id
            , snap_id second_snap_id
            , begin_time
            , end_time
            , 'Physical Read/Write Total Bytes Per Sec' metric_name
            , metric_unit
            , ROUND(SUM(average)/POWER(2, 20), 2) awr_io_mbps
       FROM dba_hist_sysmetric_summary
       WHERE metric_name IN ('Physical Read Total Bytes Per Sec', 'Physical Write Total Bytes Per Sec')
       GROUP BY snap_id
              , instance_number
              , dbid
              , begin_time
              , end_time
           -- , metric_name
              , metric_unit
       ORDER BY instance_number
              , first_snap_id
     )
WHERE first_snap_id <> 0
;
