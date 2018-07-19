REM
REM     Script:        check_sql_multiple_execution_plans_2.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Jul 19, 2018
REM
REM     Last tested
REM             11.2.0.4
REM     Purpose:  
REM             This sql script usually checks whether there have multiple execution plans for the sql specified.
REM

SET LINESIZE 200
SET PAGESIZE 200

SET VERIFY OFF

COLUMN sample_time FORMAT a25
COLUMN sql_id      FORMAT a13

SELECT h.sql_id
       , s.hash_value
       , h.sql_plan_hash_value
       , count(*) AS total_num
FROM dba_hist_active_sess_history h, v$sql s
-- FROM v$active_session_history h, v$sql s
WHERE h.sql_id = s.sql_id
AND h.sample_time BETWEEN to_date('&start_time', 'yyyy-mm-dd hh24:mi:ss')
                  AND to_date('&end_time', 'yyyy-mm-dd hh24:mi:ss')
AND h.sql_id = '&sql_id'
GROUP BY h.sql_plan_hash_value
         , h.sql_id
         , s.hash_value
ORDER BY total_num desc
         , h.sql_plan_hash_value
/

SET VERIFY ON

SET LINESIZE 80
SET PAGESIZE 14
