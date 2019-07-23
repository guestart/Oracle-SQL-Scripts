REM
REM     Script:     brst_scheduler.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 23, 2019
REM
REM     Purpose:
REM         This SQL script file usually creates a user-defined job 'BRST_JOB' on schema SZD_BBS_V2.
REM         The primary intention is it could regularly/periodically execute my procedure 'brgs_role_syn_tab' on schema SZD_BBS_V2.
REM

PROMPT ================================
PROMPT Executing on "SZD_BBS_V2" schema
PROMPT ================================

CONN /@szd_bbs_v2;

-- For instance, repeat_interval    =>  'FREQ=DAILY; BYHOUR=4;',

CREATE OR REPLACE PROCEDURE brst_scheduler  -- brst is the first letter abbreviation of my procedure name "brgs_role_syn_tab"
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name           =>  'BRST_JOB',
     job_type           =>  'STORED_PROCEDURE',
     job_action         =>  'brgs_role_syn_tab;',
     start_date         =>  '23-JUL-2019 10:00:00 AM China/Beijing',
     repeat_interval    =>  'FREQ=HOURLY; INTERVAL=5;',
     end_date           =>  NULL,
     auto_drop          =>  false,
     enabled            =>  true,
     job_class          =>  'DEFAULT_JOB_CLASS',
     comments           =>  'Batch grant select and create public synonym');
END;
/
