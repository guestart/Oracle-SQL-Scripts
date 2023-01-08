REM
REM     Script:        dbtime_dbcpu.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Aug 11, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the value of "DB time" and "DB CPU" (captured by interval 1 minute) in recent 1 hour on oracle database.
REM

-- Database CPU Time Ratio             % Cpu/DB_Time
-- Database Time Per Sec               CentiSeconds Per Second
-- Database Wait Time Ratio            % Wait/DB_Time

SET LINESIZE 200
SET PAGESIZE 300

COLUMN sample_time FORMAT a11
COLUMN metric_name FORMAT a25
COLUMN value       FORMAT 999,999.9999

WITH
db_time AS
(
  SELECT inst_id
       , TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , DECODE(metric_name, 'Database Time Per Sec', 'Database Time') metric_name
       , ROUND(value/1e2, 4) value
  FROM gv$sysmetric_history
  WHERE metric_name = 'Database Time Per Sec'
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY inst_id, sample_time
), 
cwt_ratio AS
(
  SELECT inst_id
       , TO_CHAR(end_time, 'hh24:mi:ss') sample_time
       , metric_name
       , ROUND(value/1e2, 2) value
  FROM gv$sysmetric_history
  WHERE metric_name IN ('Database CPU Time Ratio', 'Database Wait Time Ratio')
  AND   group_id = 2
  AND   end_time >= SYSDATE - INTERVAL '60' MINUTE
  ORDER BY inst_id, sample_time
)
SELECT dt.inst_id
     , dt.sample_time
     , DECODE(cwr.metric_name, 'Database CPU Time Ratio', 'DB CPU Time', 'Database Wait Time Ratio', 'DB Wait Time') metric_name
     , dt.value*cwr.value value
FROM db_time dt, cwt_ratio cwr
WHERE dt.inst_id = cwr.inst_id
AND   dt.sample_time = cwr.sample_time
ORDER BY dt.inst_id, dt.sample_time, metric_name;
