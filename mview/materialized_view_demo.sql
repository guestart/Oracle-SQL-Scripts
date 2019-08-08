REM
REM     Script:     materialized_view_demo.sql
REM     Author:     Quanwen Zhao
REM     Dated:      Aug 08, 2019
REM
REM     Purpose:
REM         This SQL script uses to create a demo of oracle materialized view on 'TEST' schema,
REM         by the way I guide you how to periodically (via using an oracle job) and manually refresh it.
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;

GRANT create job TO test;
GRANT create materialized view TO test;
GRANT drop any materialized view TO test;
GRANT on commit refresh TO test;

PROMPT ==========================
PROMPT Executing on "TEST" schema
PROMPT ==========================

CONN test/test;

SET linesize 200
SET pagesize 50
 
CREATE SEQUENCE t_id
  START WITH    1
  INCREMENT BY  1
  NOCACHE
  NOCYCLE
;

CREATE TABLE t (id NUMBER PRIMARY KEY, name VARCHAR2(30));

INSERT INTO t VALUES (t_id.nextval, 'Quanwen Zhao');
INSERT INTO t VALUES (t_id.nextval, 'Zlatko Sirotic');
INSERT INTO t VALUES (t_id.nextval, 'Sven Weller');
INSERT INTO t VALUES (t_id.nextval, 'L Fernigrini');
INSERT INTO t VALUES (t_id.nextval, 'Cookie Monster');
INSERT INTO t VALUES (t_id.nextval, 'Jara Mill');
INSERT INTO t VALUES (t_id.nextval, 'Paul Zip');

COMMIT;

EXEC DBMS_STATS.gather_table_stats(ownname=>'TEST', tabname=>'T');

CREATE MATERIALIZED VIEW mv_t
REFRESH FAST ON COMMIT
START WITH SYSDATE
NEXT SYSDATE+25/24/60
AS
   SELECT id
          , name
   FROM t
   ORDER BY id
;

-- TEST@xxxx> CREATE MATERIALIZED VIEW mv_t
--   2  REFRESH FAST ON COMMIT  <<==
--   3  START WITH SYSDATE      <<==
--   4  NEXT SYSDATE+25/24/60   <<==
--   5  AS
--   6     SELECT id
--   7            , name
--   8     FROM t
--   9     ORDER BY id
--  10  ;
--    FROM t
--         *
-- ERROR at line 8:
-- ORA-12051: ON COMMIT attribute is incompatible with other options

-- Please read the section "ON COMMIT Clause" of "https://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_6002.htm#SQLRF01302".
-- It says like this "You cannot specify both ON COMMIT and ON DEMAND. If you specify ON COMMIT, then you cannot also specify START WITH or NEXT".

CREATE MATERIALIZED VIEW mv_t
REFRESH FAST ON COMMIT
-- START WITH SYSDATE
-- NEXT SYSDATE+25/24/60
AS
   SELECT id
          , name
   FROM t
   ORDER BY id
;

-- TEST@xxxx> CREATE MATERIALIZED VIEW mv_t
--   2  REFRESH FAST ON COMMIT
--   3  -- START WITH SYSDATE
--   4  -- NEXT SYSDATE+25/24/60
--   5  AS
--   6     SELECT id
--   7            , name
--   8     FROM t
--   9     ORDER BY id
--  10  ;
--    FROM t
--         *
-- ERROR at line 8:
-- ORA-23413: table "TEST"."T" does not have a materialized view log

CREATE MATERIALIZED VIEW LOG ON t
WITH PRIMARY KEY
INCLUDING NEW VALUES
;

CREATE MATERIALIZED VIEW mv_t
REFRESH FAST ON COMMIT
AS
   SELECT id
          , name
   FROM t
   ORDER BY id
;

COLUMN log_owner          FORMAT a8
COLUMN master             FORMAT a8
COLUMN log_table          FORMAT a8
COLUMN primary_key        FORMAT a11   
COLUMN include_new_values FORMAT a18

SELECT log_owner
       , master
       , log_table
       , primary_key
       , include_new_values
FROM user_mview_logs
/

LOG_OWNE MASTER   LOG_TABL PRIMARY_KEY INCLUDE_NEW_VALUES
-------- -------- -------- ----------- ------------------
TEST     T        MLOG$_T  YES         YES

INSERT INTO t VALUES (t_id.nextval, 'Mark Powell');
INSERT INTO t VALUES (t_id.nextval, 'Andrew Sayer');

-- TEST@xxxx> insert into t values (t_id.nextval, 'Mark Powell');
-- 
-- 1 row created.
-- 
-- TEST@xxxx> insert into t values (t_id.nextval, 'Andrew Sayer');
-- 
-- 1 row created.

-- TEST@xxxx> 
-- TEST@xxxx> select * from t;
-- 
--         ID NAME
-- ---------- ------------------------------------------------------------
--          1 Quanwen Zhao
--          2 Zlatko Sirotic
--          3 Sven Weller
--          4 L Fernigrini
--          5 Cookie Monster
--          6 Jara Mill
--          7 Paul Zip
--          8 Mark Powell
--          9 Andrew Sayer
-- 
-- 9 rows selected.

-- TEST@xxxx> select * from mv_t;
-- 
--         ID NAME
-- ---------- ------------------------------------------------------------
--          1 Quanwen Zhao
--          2 Zlatko Sirotic
--          3 Sven Weller
--          4 L Fernigrini
--          5 Cookie Monster
--          6 Jara Mill
--          7 Paul Zip
-- 
-- 7 rows selected.

CREATE OR REPLACE PROCEDURE refresh_t_scheduler
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
     job_type          => 'PLSQL_BLOCK',
     job_action        => 'begin DBMS_MVIEW.refresh('mv_t','f'); end;',
     start_date        => SYSDATE,
     repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
     end_date          => SYSDATE+25/24/60,
     auto_drop         => false,
     enabled           => true,
     job_class         => 'DEFAULT_JOB_CLASS',
     comments          => 'Regularly refreshing MView mv_t');
END;
/

-- TEST@xxxx> CREATE OR REPLACE PROCEDURE refresh_t_scheduler
--   2  IS
--   3  BEGIN
--   4    DBMS_SCHEDULER.create_job (
--   5       job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
--   6       job_type          => 'PLSQL_BLOCK',
--   7       job_action        => 'begin DBMS_MVIEW.refresh('mv_t','f'); end;',
--   8       start_date        => SYSDATE,
--   9       repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
--  10       end_date          => SYSDATE+25/24/60,
--  11       auto_drop         => false,
--  12       enabled           => true,
--  13       job_class         => 'DEFAULT_JOB_CLASS',
--  14       comments          => 'Regularly refreshing MView mv_t');
--  15  END;
--  16  /
-- 
-- Warning: Procedure created with compilation errors.

-- TEST@xxxx> show errors
-- Errors for PROCEDURE REFRESH_T_SCHEDULER:
-- 
-- LINE/COL ERROR
-- -------- -----------------------------------------------------------------
-- 7/54     PLS-00103: Encountered the symbol "MV_T" when expecting one of
--          the following:
--          ) , * & = - + < / > at in is mod remainder not rem
--          <an exponent (**)> <> or != or ~= >= <= <> and or like like2
--          like4 likec between || multiset member submultiset

-- After you read my this thread "https://community.oracle.com/thread/4284415" on ODC (Oracle Developer Community).
-- 
-- Perhaps you'll understand everything.

CREATE OR REPLACE PROCEDURE refresh_t_scheduler
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
     job_type          => 'PLSQL_BLOCK',
     job_action        => 'begin DBMS_MVIEW.refresh("mv_t","f"); end;', -- this time I use a couple of double quotation marks to quote the value of parameter.
     start_date        => SYSDATE,
     repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
     end_date          => SYSDATE+25/24/60,
     auto_drop         => false,
     enabled           => true,
     job_class         => 'DEFAULT_JOB_CLASS',
     comments          => 'Regularly refreshing MView mv_t');
END;
/

-- TEST@xxxx> CREATE OR REPLACE PROCEDURE refresh_t_scheduler
--   2  IS
--   3  BEGIN
--   4    DBMS_SCHEDULER.create_job (
--   5       job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
--   6       job_type          => 'PLSQL_BLOCK',
--   7       job_action        => 'begin DBMS_MVIEW.refresh("mv_t","f"); end;', -- this time I use a couple of double quotation marks to quote the value of parameter.
--   8       start_date        => SYSDATE,
--   9       repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
--  10       end_date          => SYSDATE+25/24/60,
--  11       auto_drop         => false,
--  12       enabled           => true,
--  13       job_class         => 'DEFAULT_JOB_CLASS',
--  14       comments          => 'Regularly refreshing MView mv_t');
--  15  END;
--  16  /
-- 
-- Procedure created.

-- or,

CREATE OR REPLACE PROCEDURE refresh_t_scheduler
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
     job_type          => 'PLSQL_BLOCK',
     job_action        => 'begin DBMS_MVIEW.refresh(''mv_t'',''f''); end;', -- this time I use a couple of two number of single quotation mark to quote the value of parameter.
     start_date        => SYSDATE,
     repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
     end_date          => SYSDATE+25/24/60,
     auto_drop         => false,
     enabled           => true,
     job_class         => 'DEFAULT_JOB_CLASS',
     comments          => 'Regularly refreshing MView mv_t');
END;
/

-- TEST@xxxx> CREATE OR REPLACE PROCEDURE refresh_t_scheduler
--   2  IS
--   3  BEGIN
--   4    DBMS_SCHEDULER.create_job (
--   5       job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
--   6       job_type          => 'PLSQL_BLOCK',
--   7       job_action        => 'begin DBMS_MVIEW.refresh(''mv_t'',''f''); end;', -- this time I use a couple of two number of single quotation mark to quote the value of parameter.
--   8       start_date        => SYSDATE,
--   9       repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
--  10       end_date          => SYSDATE+25/24/60,
--  11       auto_drop         => false,
--  12       enabled           => true,
--  13       job_class         => 'DEFAULT_JOB_CLASS',
--  14       comments          => 'Regularly refreshing MView mv_t');
--  15  END;
--  16  /
-- 
-- Procedure created.

-- or,

CREATE OR REPLACE PROCEDURE refresh_t_scheduler
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
     job_type          => 'PLSQL_BLOCK',
     job_action        => q'~begin DBMS_MVIEW.refresh('mv_t','f'); end;~', -- this time I use the "q quoting mechanism" (it's commonly used since Oracle 10.1) to quote the value of parameter.
     start_date        => SYSDATE,
     repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
     end_date          => SYSDATE+25/24/60,
     auto_drop         => false,
     enabled           => true,
     job_class         => 'DEFAULT_JOB_CLASS',
     comments          => 'Regularly refreshing MView mv_t');
END;
/

-- TEST@xxxx> CREATE OR REPLACE PROCEDURE refresh_t_scheduler
--   2  IS
--   3  BEGIN
--   4    DBMS_SCHEDULER.create_job (
--   5       job_name          => 'RTS_JOB', -- rts is the first letter abbreviation of procedure name "refresh_t_scheduler".
--   6       job_type          => 'PLSQL_BLOCK',
--   7       job_action        => q'~begin DBMS_MVIEW.refresh('mv_t','f'); end;~', -- this time I use the "q quoting mechanism" (it's commonly used since Oracle 10.1) to quote the value of parameter.
--   8       start_date        => SYSDATE,
--   9       repeat_interval   => 'FREQ=MINUTELY; INTERVAL=5;',
--  10       end_date          => SYSDATE+25/24/60,
--  11       auto_drop         => false,
--  12       enabled           => true,
--  13       job_class         => 'DEFAULT_JOB_CLASS',
--  14       comments          => 'Regularly refreshing MView mv_t');
--  15  END;
--  16  /
-- 
-- Procedure created.

-- TEST@xxxx> 
-- TEST@xxxx> exec refresh_t_scheduler
-- 
-- PL/SQL procedure successfully completed.

COLUMN log_date FORMAT a35
COLUMN owner    FORMAT a12
COLUMN status   FORMAT a12

-- TEST@xxxx> select log_id, log_date, owner, status from user_scheduler_job_log where job_name = 'RTS_JOB' order by 2;
-- 
--     LOG_ID LOG_DATE                            OWNER        STATUS
-- ---------- ----------------------------------- ------------ ------------
--      90900 06-AUG-19 04.36.09.219513 PM +08:00 TEST         FAILED
--      90901 06-AUG-19 04.41.09.042880 PM +08:00 TEST         FAILED
--      90902 06-AUG-19 04.46.09.048793 PM +08:00 TEST         FAILED
--      90904 06-AUG-19 04.51.09.044790 PM +08:00 TEST         FAILED
--      90905 06-AUG-19 04.56.09.046098 PM +08:00 TEST         FAILED
--      90906 06-AUG-19 04.56.09.048318 PM +08:00 TEST
-- 
-- 6 rows selected.

COLUMN start_date  FORMAT a38
COLUMN job_creator FORMAT a12
COLUMN state       FORMAT a11

-- TEST@xxxx> select start_date, job_creator, state, run_count, max_runs from user_scheduler_jobs where job_name = 'RTS_JOB';
-- 
-- START_DATE                             JOB_CREATOR  STATE        RUN_COUNT   MAX_RUNS
-- -------------------------------------- ------------ ----------- ---------- ----------
-- 06-AUG-19 04.36.09.000000 PM +08:00    TEST         COMPLETED            5

-- The next day I check materialized view "mv_t" and those two number of data has been shown.
-- 
-- TEST@xxxx> select * from mv_t;
-- 
--         ID NAME
-- ---------- ------------------------------------------------------------
--          1 Quanwen Zhao
--          2 Zlatko Sirotic
--          3 Sven Weller
--          4 L Fernigrini
--          5 Cookie Monster
--          6 Jara Mill
--          7 Paul Zip
--          8 Mark Powell
--          9 Andrew Sayer
-- 
-- 9 rows selected.

-- Manually and fast refresh MView "mv_t".

BEGIN
  DBMS_MVIEW.refresh('mv_t','f');
END;
/

-- TEST@xxxx> BEGIN
--   2    DBMS_MVIEW.refresh('mv_t','f');
--   3  END;
--   4  /
-- 
-- PL/SQL procedure successfully completed.

BEGIN
  DBMS_MVIEW.refresh("mv_t","f");
END;
/

-- TEST@xxxx> BEGIN
--   2    DBMS_MVIEW.refresh("mv_t","f");
--   3  END;
--   4  /
--   DBMS_MVIEW.refresh("mv_t","f");
--                       *
-- ERROR at line 2:
-- ORA-06550: line 2, column 23:
-- PLS-00201: identifier 'mv_t' must be declared
-- ORA-06550: line 2, column 3:
-- PL/SQL: Statement ignored

EXEC DBMS_MVIEW.refresh('mv_t', 'f');

-- TEST@xxxx> exec DBMS_MVIEW.refresh('mv_t', 'f');
-- 
-- PL/SQL procedure successfully completed.

EXEC DBMS_MVIEW.refresh(tab=>'mv_t', method=>'f');

-- TEST@xxxx> exec DBMS_MVIEW.refresh(tab => 'mv_t', method => 'f');
-- BEGIN DBMS_MVIEW.refresh(tab => 'mv_t', method => 'f'); END;
-- 
--       *
-- ERROR at line 1:
-- ORA-06550: line 1, column 7:
-- PLS-00306: wrong number or types of arguments in call to 'REFRESH'
-- ORA-06550: line 1, column 7:
-- PL/SQL: Statement ignored

-- TEST@xxxx> exec DBMS_MVIEW.refresh('mv_t', method => 'fast');
-- 
-- PL/SQL procedure successfully completed.

-- After I read https://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_mview.htm#ARPLS67203
-- 
-- Replace the parameter name "tab" with "list".

-- TEST@xxxx> exec DBMS_MVIEW.refresh(list => 'mv_t', method => 'fast');
-- 
-- PL/SQL procedure successfully completed.
