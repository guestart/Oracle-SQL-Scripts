REM
REM     Script:        scheduler_jobs.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 30, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking all of the jobs situation with scheduler using the view dba_scheduler_jobs of oracle database.
REM

SELECT JOB_NAME,
       OWNER,
       to_char(NEXT_RUN_DATE, 'yyyy-MM-dd HH:mi:ss')   as NEXT_RUN_DATE,
       to_char(LAST_START_DATE, 'yyyy-MM-dd HH:mi:ss') as LAST_START_DATE,
       STATE,
       ENABLED,
       JOB_CLASS,
       RUN_COUNT,
       SCHEDULE_OWNER,
       SCHEDULE_NAME,
       DECODE(BITAND(FLAGS, 512 + 1024 + 2048 + 4096 + 8192 + 16384 + 2 + 1), 512, 'PLSQL_EXPR', 1024, 'NAMED',
              1024 + 1, 'NON_EXIST', 2048, 'CALENDAR_STRING', 4096, 'WINDOW', 4096 + 2, 'WINDOW_GROUP', 8192,
              'ONCE', 16384, 'NOW', '') AS SCHEDULE_TYPE
FROM DBA_SCHEDULER_JOBS
WHERE JOB_SUBNAME IS NULL;
