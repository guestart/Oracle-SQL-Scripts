REM
REM      Script:     bgs_scheduler.sql
REM      Author:     Quanwen Zhao
REM      Dated:      Jul 29, 2019
REM      Updated:    Aug 07, 2019
REM                  When running this user-defined stored procedure you'll encounter this weird error:
REM
REM                  PROD@xxxx> CREATE OR REPLACE PROCEDURE bgs_scheduler
REM                    2  IS
REM                    3  BEGIN
REM                    4    DBMS_SCHEDULER.create_job (
REM                    5       job_name          => 'BS_JOB', -- bs is the first letter abbreviation of procedure name "bgs_scheduler".
REM                    6       job_type          => 'PLSQL_BLOCK',
REM                    7       job_action        => 'begin dbms_mview.refresh('u_tables','c'); end;',
REM                    8       start_date        => SYSTIMESTAMP,
REM                    9       repeat_interval   => 'FREQ=DAILY; BYHOUR=4;',
REM                    10       end_date          => NULL,
REM                    11       auto_drop         => false,
REM                    12       enabled           => true,
REM                    13       job_class         => 'DEFAULT_JOB_CLASS',
REM                    14       comments          => 'Regularly refreshing MView u_tables');
REM                    15  END;
REM                    16  /
REM
REM                  Warning: Procedure created with compilation errors.
REM
REM                  PROD@xxxx> show errors
REM                  Errors for PROCEDURE BGS_SCHEDULER:
REM
REM                  LINE/COL ERROR
REM                  -------- -----------------------------------------------------------------
REM                  7/54     PLS-00103: Encountered the symbol "U_TABLES" when expecting one
REM                           of the following:
REM                           ) , * & = - + < / > at in is mod remainder not rem
REM                           <an exponent (**)> <> or != or ~= >= <= <> and or like like2
REM                           like4 likec between || multiset member submultiset
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

-- As you can see from my updated seciotn at Aug 07, 2019. I encountered a weird error 'PLS-00103'.
-- Luckily you can read my such similar a thread 'https://community.oracle.com/thread/4284415' on Oracle Developer Community.
-- Oracle experts both 'Mustafa KALAYCI' and 'ascheffer' all gave me better solution.
