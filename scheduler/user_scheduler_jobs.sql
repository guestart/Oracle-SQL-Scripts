REM
REM     Script:     user_scheduler_jobs.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Aug 08, 2019
REM
REM     Purpose:
REM         This SQL script uses to check the some information of the oracle scheduer/job on 'TEST' schema.
REM

PROMPT ==========================
PROMPT Executing on "TEST" schema
PROMPT ==========================

CONN test/test;

SET LINESIZE 200
SET PAGESIZE 50

COLUMN  start_date   FORMAT  a38
COLUMN  job_creator  FORMAT  a12
COLUMN  state        FORMAT  a11

SELECT start_date
       , job_creator
       , state
       , run_count
       , max_runs
FROM user_scheduler_jobs
WHERE job_name = 'RTS_JOB'
/

-- A detailed demo.
-- 
-- TEST@xxxx> select start_date, job_creator, state, run_count, max_runs from user_scheduler_jobs where job_name = 'RTS_JOB';
-- 
-- START_DATE                             JOB_CREATOR  STATE        RUN_COUNT   MAX_RUNS
-- -------------------------------------- ------------ ----------- ---------- ----------
-- 06-AUG-19 04.36.09.000000 PM +08:00    TEST         COMPLETED            6
