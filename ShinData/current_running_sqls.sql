REM
REM     Script:        current_running_sqls.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 02, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the current running sql statements of oracle database.
REM

SELECT s.inst_id,
       s.sid,
       s.schemaname,
       s.serial# AS serial,
       s.machine,
       s.program,
       s.sql_id,
       t.sql_text,
       s.sql_exec_start,
       ceil((sysdate - s.sql_exec_start) * 24 * 60 * 60) AS sql_exec_time
FROM gv$session s, gv$sqlstats t
WHERE not exists (select * from (SELECT username
                                 FROM dba_users
                                 WHERE created < (SELECT created FROM v$database)
                                ) u
                  where s.schemaname = u.username
                 )
AND s.sql_id IS NOT NULL
AND s.status = 'ACTIVE'
AND s.sql_id = t.sql_id
AND s.inst_id = t.inst_id;
