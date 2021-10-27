REM
REM     Script:        acquire_logic_cpus_union_aas.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 27, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             21.3.0.0
REM
REM     Purpose:
REM       The code snippets visualizing the oracle performance metrics "NUM_CPUS" and "AAS" in the past and real time by the custom report of SQL Developer
REM       is based on "CPU_LOAD" about "dhos" (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_cpu_load.sql)
REM       and "AAS" (https://github.com/guestart/Oracle-SQL-Scripts/blob/master/awr_trend/acquire_aas_2.sql).
REM
REM     References:
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_SYSMETRIC_SUMMARY.html#GUID-E6377E5F-1FFF-4563-850F-C361B9D85048
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/DBA_HIST_OSSTAT.html#GUID-C94C3F25-ADE2-4E4C-B942-C0D14D9441D8
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-SYSMETRIC_HISTORY.html#GUID-5560D15E-9F02-4300-B4DD-85A88A280392
REM       https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/V-OSSTAT.html#GUID-E1E48692-47FA-4AE3-9402-82477E66FFC0
REM

-- Average Active Sessions & Logic CPUs in Last 31 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date  FORMAT a12
COLUMN stat_name  FORMAT a25
COLUMN stat_value FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas_per_hour AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
       , metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Active Sessions'
  AND   end_time >= SYSDATE - 30
),
aas AS
(
  SELECT snap_date                                    -- the group column
       , metric_name                                  -- the series column
       , ROUND(SUM(average)/COUNT(snap_date), 2) aas  -- the value column
  FROM aas_per_hour
  GROUP BY snap_date
         , metric_name
),
oscpu AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , stat_name
       , value
  FROM dba_hist_osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT DISTINCT s.snap_date                                     -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM aas_per_hour s
   , oscpu u
WHERE s.snap_id = u.snap_id
AND   s.dbid = u.dbid
AND   s.instance_number = u.instance_number
UNION ALL
SELECT snap_date              -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date
;

-- Average Active Sessions & Logic CPUs in Last 31 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date_time FORMAT a19
COLUMN stat_name      FORMAT a25
COLUMN stat_value     FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time
       , metric_name
       , ROUND(average, 2) aas
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Active Sessions'
  AND   end_time >= SYSDATE - 30
),
oscpu AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , stat_name
       , value
  FROM dba_hist_osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT s.snap_date_time                                         -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM aas s
   , oscpu u
WHERE s.snap_id = u.snap_id
AND   s.dbid = u.dbid
AND   s.instance_number = u.instance_number
UNION ALL
SELECT snap_date_time         -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date_time
;

-- Average Active Sessions & Logic CPUs in Last 7 Days (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date  FORMAT a12
COLUMN stat_name  FORMAT a25
COLUMN stat_value FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas_per_hour AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
       , metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Active Sessions'
  AND   end_time >= SYSDATE - 6
),
aas AS
(
  SELECT snap_date                                    -- the group column
       , metric_name                                  -- the series column
       , ROUND(SUM(average)/COUNT(snap_date), 2) aas  -- the value column
  FROM aas_per_hour
  GROUP BY snap_date
         , metric_name
),
oscpu AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , stat_name
       , value
  FROM dba_hist_osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT DISTINCT s.snap_date                                     -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM aas_per_hour s
   , oscpu u
WHERE s.snap_id = u.snap_id
AND   s.dbid = u.dbid
AND   s.instance_number = u.instance_number
UNION ALL
SELECT snap_date              -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date
;

-- Average Active Sessions & Logic CPUs in Last 7 Days (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date_time FORMAT a19
COLUMN stat_name      FORMAT a25
COLUMN stat_value     FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time
       , metric_name
       , ROUND(average, 2) aas
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Active Sessions'
  AND   end_time >= SYSDATE - 6
),
oscpu AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , stat_name
       , value
  FROM dba_hist_osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT s.snap_date_time                                         -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM aas s
   , oscpu u
WHERE s.snap_id = u.snap_id
AND   s.dbid = u.dbid
AND   s.instance_number = u.instance_number
UNION ALL
SELECT snap_date_time         -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date_time
;

-- Average Active Sessions & Logic CPUs in Last 24 Hours.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date_time FORMAT a19
COLUMN stat_name      FORMAT a25
COLUMN stat_value     FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time
       , metric_name
       , ROUND(average, 2) aas
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Active Sessions'
  AND   end_time >= SYSDATE - 1
),
oscpu AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , stat_name
       , value
  FROM dba_hist_osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT s.snap_date_time                                         -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM aas s
   , oscpu u
WHERE s.snap_id = u.snap_id
AND   s.dbid = u.dbid
AND   s.instance_number = u.instance_number
UNION ALL
SELECT snap_date_time         -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date_time
;

-- Average Active Sessions & Logic CPUs in Real Time.

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date_time FORMAT a19
COLUMN stat_name      FORMAT a25
COLUMN stat_value     FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas AS
(
  SELECT TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time
       , metric_name
       , ROUND(value, 2) aas
  FROM v$sysmetric_history
  WHERE metric_name = 'Average Active Sessions'
  AND   group_id = 2
),
oscpu AS
(
  SELECT stat_name
       , value
  FROM v$osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT s.snap_date_time                                         -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM oscpu u  -- "oscpu" has only a row, so using "oscpu" and "aas" to join each other to acquire the column "snap_date_time" of "aas".
   , aas s
UNION ALL
SELECT snap_date_time         -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date_time
;

-- Average Active Sessions & Logic CPUs Custom Time Period (interval by each day).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date  FORMAT a12
COLUMN stat_name  FORMAT a25
COLUMN stat_value FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas_per_hour AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , TO_CHAR(end_time, 'yyyy-mm-dd') snap_date
       , metric_name
       , average
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Active Sessions'
  AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd')
                  AND     TO_DATE(:end_date, 'yyyy-mm-dd')
        )
),
aas AS
(
  SELECT snap_date                                    -- the group column
       , metric_name                                  -- the series column
       , ROUND(SUM(average)/COUNT(snap_date), 2) aas  -- the value column
  FROM aas_per_hour
  GROUP BY snap_date
         , metric_name
),
oscpu AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , stat_name
       , value
  FROM dba_hist_osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT DISTINCT s.snap_date                                     -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM aas_per_hour s
   , oscpu u
WHERE s.snap_id = u.snap_id
AND   s.dbid = u.dbid
AND   s.instance_number = u.instance_number
UNION ALL
SELECT snap_date              -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date
;

-- Average Active Sessions & Logic CPUs Custom Time Period (interval by each hour).

SET LINESIZE 200
SET PAGESIZE 200

COLUMN snap_date_time FORMAT a19
COLUMN stat_name      FORMAT a25
COLUMN stat_value     FORMAT 999,999.99

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

WITH aas AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , TO_CHAR(end_time, 'yyyy-mm-dd hh24:mi:ss') snap_date_time
       , metric_name
       , ROUND(average, 2) aas
  FROM dba_hist_sysmetric_summary
  WHERE metric_name = 'Average Active Sessions'
  AND   (end_time BETWEEN TO_DATE(:start_date, 'yyyy-mm-dd hh24:mi:ss')
                  AND     TO_DATE(:end_date, 'yyyy-mm-dd hh24:mi:ss')
        )
),
oscpu AS
(
  SELECT snap_id
       , dbid
       , instance_number
       , stat_name
       , value
  FROM dba_hist_osstat
  WHERE stat_name = 'NUM_CPUS'
)
SELECT s.snap_date_time                                         -- the group column
     , DECODE(u.stat_name, 'NUM_CPUS', 'Logic CPUs') stat_name  -- the series column
     , u.value stat_value                                       -- the value column
FROM aas s
   , oscpu u
WHERE s.snap_id = u.snap_id
AND   s.dbid = u.dbid
AND   s.instance_number = u.instance_number
UNION ALL
SELECT snap_date_time         -- the group column
     , metric_name stat_name  -- the series column
     , aas stat_value         -- the value column
FROM aas
ORDER BY stat_name DESC
       , snap_date_time
;
