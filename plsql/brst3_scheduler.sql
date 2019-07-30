REM
REM     Script:     brst3_scheduler.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 30, 2019
REM
REM     Purpose:
REM         This SQL script file usually creates a user-defined job 'BRST3_JOB' on schema SZD_BBS_V2.
REM         The primary intention is it could regularly/periodically execute my procedure 'rgy_refresh_mview_uts' on schema SZD_BBS_V2.
REM

PROMPT ================================
PROMPT Executing on "SZD_BBS_V2" schema
PROMPT ================================

CONN /@szd_bbs_v2;

-- repeat_interval    =>  'FREQ=HOURLY; INTERVAL=5;',

CREATE OR REPLACE PROCEDURE brst3_scheduler  -- brst3 is the first letter abbreviation of my procedure name "brgs_role_syn_tab_3"
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name           =>  'BRST3_JOB',
     job_type           =>  'STORED_PROCEDURE',
     job_action         =>  'rgy_refresh_mview_uts',
     start_date         =>  SYSDATE, -- using this parameter, it's okay
     repeat_interval    =>  'FREQ=DAILY; BYHOUR=4;',
     end_date           =>  NULL,
     auto_drop          =>  false,
     enabled            =>  true,
     job_class          =>  'DEFAULT_JOB_CLASS',
     comments           =>  'Batch grant select and create public synonym');
END;
/
