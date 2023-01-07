REM
REM     Script:        redo_total_size_in_recent_1_hour.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Oct 29, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the generated redo total size of oracle database in recent 1 hour.
REM

SELECT * FROM (
WITH times AS
 (SELECT /*+ MATERIALIZE */
   hour_end_time
    FROM (SELECT (TRUNC(SYSDATE, 'HH') + (2 / 24)) - (ROWNUM / 24) hour_end_time
            FROM DUAL
          CONNECT BY ROWNUM <= (1 * 24) + 3),
         v$database
   WHERE log_mode = 'ARCHIVELOG')
SELECT hour_end_time, NVL(ROUND(SUM(size_mb), 3), 0) size_mb, i.instance_name
  FROM(
SELECT hour_end_time, CASE WHEN(hour_end_time - (1 / 24)) > lag_next_time THEN(next_time + (1 / 24) - hour_end_time) * (size_mb / (next_time - lag_next_time)) ELSE 0 END + CASE WHEN hour_end_time < lead_next_time THEN(hour_end_time - next_time) * (lead_size_mb / (lead_next_time - next_time)) ELSE 0 END + CASE WHEN lag_next_time > (hour_end_time - (1 / 24)) THEN size_mb ELSE 0 END + CASE WHEN next_time IS NULL THEN(1 / 24) * LAST_VALUE(CASE WHEN next_time IS NOT NULL AND lag_next_time IS NULL THEN 0 ELSE(size_mb / (next_time - lag_next_time)) END IGNORE NULLS) OVER(
 ORDER BY hour_end_time DESC, next_time DESC) ELSE 0 END size_mb
  FROM(
SELECT t.hour_end_time, arc.next_time, arc.lag_next_time, LEAD(arc.next_time) OVER(
 ORDER BY arc.next_time ASC) lead_next_time, arc.size_mb, LEAD(arc.size_mb) OVER(
 ORDER BY arc.next_time ASC) lead_size_mb
  FROM times t,(
SELECT next_time, size_mb, LAG(next_time) OVER(
 ORDER BY next_time) lag_next_time
  FROM(
SELECT next_time, SUM(size_mb) size_mb
  FROM(
SELECT DISTINCT a.sequence#, a.next_time, ROUND(a.blocks * a.block_size / 1024 / 1024) size_mb
  FROM v$archived_log a,(
SELECT /*+ no_merge */
CASE WHEN TO_NUMBER(pt.VALUE) = 0 THEN 1 ELSE TO_NUMBER(pt.VALUE) END VALUE
  FROM v$parameter pt
 WHERE pt.name = 'thread') pt
 WHERE a.next_time > SYSDATE - 3 AND a.thread# = pt.VALUE AND ROUND(a.blocks * a.block_size / 1024 / 1024) > 0)
 GROUP BY next_time)) arc
 WHERE t.hour_end_time = (TRUNC(arc.next_time(+), 'HH') + (1 / 24)))
 WHERE hour_end_time > TRUNC(SYSDATE, 'HH') - 1 - (1 / 24)), v$instance i
 WHERE hour_end_time <= TRUNC(SYSDATE, 'HH')
 GROUP BY hour_end_time, i.instance_name
 ORDER BY hour_end_time DESC
) WHERE ROWNUM =1;

-- hour_end_time       size_mb instance_name
-- ------------------- ------- -------------
-- 2022-10-26 16:00:00	 6.015 orcl
