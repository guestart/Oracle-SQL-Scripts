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

COLUMN job_name        FORMAT a12
COLUMN job_creator     FORMAT a12
COLUMN job_type        FORMAT a16
COLUMN job_action      FORMAT a30
COLUMN start_date      FORMAT a38
COLUMN repeat_interval FORMAT a25
COLUMN end_date        FORMAT a38
COLUMN auto_drop       FORMAT a5
COLUMN enabled         FORMAT a5
COLUMN job_class       FORMAT a17
COLUMN comments        FORMAT a30
COLUMN state           FORMAT a9
COLUMN run_count       FORMAT 99
COLUMN max_runs        FORMAT 99

SELECT job_name
       , job_creator
       , job_type
--     , job_action
--     , start_date
       , repeat_interval
--     , end_date
--     , auto_drop
--     , enabled
       , job_class
--     , comments
       , state
       , run_count
       , max_runs
FROM user_scheduler_jobs
;

-- A detailed demo. 
-- TEST@xxxx> SET LINESIZE 200
-- TEST@xxxx> SET PAGESIZE 50
-- TEST@xxxx> 
-- TEST@xxxx> COLUMN job_name        FORMAT a12
-- TEST@xxxx> COLUMN job_creator     FORMAT a12
-- TEST@xxxx> COLUMN job_type        FORMAT a16
-- TEST@xxxx> COLUMN job_action      FORMAT a30
-- TEST@xxxx> COLUMN start_date      FORMAT a38
-- TEST@xxxx> COLUMN repeat_interval FORMAT a28
-- TEST@xxxx> COLUMN end_date        FORMAT a38
-- TEST@xxxx> COLUMN auto_drop       FORMAT a5
-- TEST@xxxx> COLUMN enabled         FORMAT a5
-- TEST@xxxx> COLUMN job_class       FORMAT a17
-- TEST@xxxx> COLUMN comments        FORMAT a30
-- TEST@xxxx> COLUMN state           FORMAT a9
-- TEST@xxxx> COLUMN run_count       FORMAT 99
-- TEST@xxxx> COLUMN max_runs        FORMAT 99
-- TEST@xxxx> 
-- TEST@xxxx> SELECT job_name
--   2         , job_creator
--   3         , job_type
--   4  --     , job_action
--   5  --     , start_date
--   6         , repeat_interval
--   7  --     , end_date
--   8  --     , auto_drop
--   9  --     , enabled
--  10         , job_class
--  11  --     , comments
--  12         , state
--  13         , run_count
--  14         , max_runs
--  15  FROM user_scheduler_jobs
--  16  ;
-- 
-- JOB_NAME     JOB_CREATOR  JOB_TYPE         REPEAT_INTERVAL              JOB_CLASS         STATE     RUN_COUNT MAX_RUNS
-- ------------ ------------ ---------------- ---------------------------- ----------------- --------- --------- --------
-- RTS_JOB      TEST         PLSQL_BLOCK      FREQ=MINUTELY; INTERVAL=5;   DEFAULT_JOB_CLASS COMPLETED         5
