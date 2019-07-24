REM
REM     Script:     brst2_scheduler.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Jul 23, 2019
REM
REM     Purpose:
REM         This SQL script file usually creates a user-defined job 'BRST2_JOB' on schema SZD_BBS_V2.
REM         The primary intention is it could regularly/periodically execute my procedure 'brgs_role_syn_tab_2' on schema SZD_BBS_V2.
REM

PROMPT ================================
PROMPT Executing on "SZD_BBS_V2" schema
PROMPT ================================

CONN /@szd_bbs_v2;

-- repeat_interval    =>  'FREQ=HOURLY; INTERVAL=5;',

CREATE OR REPLACE PROCEDURE brst2_scheduler  -- brst2 is the first letter abbreviation of my procedure name "brgs_role_syn_tab_2"
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name           =>  'BRST2_JOB',
     job_type           =>  'STORED_PROCEDURE',
  -- job_action         =>  'brgs_role_syn_tab_2;', using this parameter, return ORA-27452: brgs_role_syn_tab_2; is an invalid name for a database object.
     job_action         =>  'brgs_role_syn_tab_2', -- when eliminating semi-colon that is at the end of value, it's okay
  -- start_date         =>  '23-JUL-2019 05:00:00 PM China/Beijing', using this parameter, return ORA-01882: timezone region not found
  -- start_date         =>  TO_DATE('2019-07-23 05:00:00', 'yyyy-mm-dd hh24:mi:ss'), using this parameter, it's okay
  -- start_date         =>  SYSDATE, using this parameter, it's okay
     start_date         =>  SYSTIMESTAMP, -- using this parameter, it's okay
     repeat_interval    =>  'FREQ=DAILY; BYHOUR=4;',
     end_date           =>  NULL,
     auto_drop          =>  false,
     enabled            =>  true,
     job_class          =>  'DEFAULT_JOB_CLASS',
     comments           =>  'Batch grant select and create public synonym');
END;
/
