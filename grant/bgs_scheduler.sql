REM
REM      Script:     bgs_scheduler.sql
REM      Author:     Quanwen Zhao
REM      Dated:      Jul 29, 2019
REM
REM      Purpose:
REM          This SQL script regularly refreshs view "u_tables" being created via running SQL script "bgs_role_syn_tab_2.sql".
REM

PROMPT ==========================
PROMPT Executing on "PROD" schema
PROMPT ==========================

CREATE OR REPLACE PROCEDURE bgs_scheduler
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name          => 'BS_JOB', -- bs is the first letter abbreviation of procedure name "bgs_scheduler".
     job_type          => 'PLSQL_BLOCK',
     job_action        => 'begin dbms_mview.refresh('u_tables','c'); end;',
     start_date        => SYSTIMESTAMP,
     repeat_interval   => 'FREQ=DAILY; BYHOUR=4;',
     end_date          => NULL,
     auto_drop         => false,
     enabled           => true,
     job_class         => 'DEFAULT_JOB_CLASS',
     comments          => 'Regularly refreshing MView u_tables');
END;
/
