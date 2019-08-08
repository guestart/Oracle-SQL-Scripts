REM
REM     Script:     user_scheduler_job_log.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Aug 08, 2019
REM
REM     Purpose:
REM         This SQL script uses to check the executing/running situation of the oracle scheduer/job log on 'TEST' schema.
REM

PROMPT ==========================
PROMPT Executing on "TEST" schema
PROMPT ==========================

CONN test/test;

SET LINESIZE 200
SET PAGESIZE 50

COLUMN  log_date  FORMAT  a35
COLUMN  owner     FORMAT  a12
COLUMN  status    FORMAT  a12

SELECT log_id
       , log_date
       , owner
       , status
FROM user_scheduler_job_log
WHERE job_name = 'RTS_JOB'
ORDER BY log_date
/

-- A detailed demo.
-- 
-- TEST@xxxx> select log_id, log_date, owner, status from user_scheduler_job_log where job_name = 'RTS_JOB' order by 2;
-- 
--     LOG_ID LOG_DATE                            OWNER        STATUS
-- ---------- ----------------------------------- ------------ ------------
--      90900 06-AUG-19 04.36.09.219513 PM +08:00 TEST         SUCCEEDED
--      90901 06-AUG-19 04.41.09.042880 PM +08:00 TEST         SUCCEEDED
--      90902 06-AUG-19 04.46.09.048793 PM +08:00 TEST         SUCCEEDED
--      90904 06-AUG-19 04.51.09.044790 PM +08:00 TEST         SUCCEEDED
--      90905 06-AUG-19 04.56.09.046098 PM +08:00 TEST         SUCCEEDED
--      90906 06-AUG-19 04.56.09.048318 PM +08:00 TEST         SUCCEEDED
-- 
-- 6 rows selected.
