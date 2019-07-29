REM
REM       Script:      scheduler_demo.sql
REM       Author:      Quanwen Zhao
REM       Dated:       Jul 29, 2019
REM
REM       Purpose:
REM           This SQL script uses to check running situation of oracle scheduler/job, the job will be executed 
REM           with inserting a sequence's next_val and a sysdate on table t from 11:00 AM to 12:00 AM. After
REM           this job executing completed I query two OSDDV (Oracle Static Data Dictionary View) - "user_scheduler_jobs"
REM           and "user_scheduler_job_log" to observe this job's executing effect.

SET LINESIZE 200
SET PAGESIZE 50

COLUMN   log_date      FORMAT   a35
COLUMN   owner         FORMAT   a12
COLUMN   status        FORMAT   a12
COLUMN   start_date    FORMAT   a38
COLUMN   job_creator   FORMAT   a12
COLUMN   state         FORMAT   a11

PROMPT ================================
PROMPT Executing on "SZD_BBS_V2" schema
PROMPT ================================

CONN /@szd_bbs_v2;

CREATE SEQUENCE t_id
START WITH      1
INCREMENT BY    1
NOCACHE
NOCYCLE
;

CREATE TABLE t (id number, dt date);

CREATE OR REPLACE PROCEDURE t_ins
IS
BEGIN
  INSERT INTO t VALUES(t_id.nextval, sysdate);
  COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE t_ins_scheduler
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name          => 'TIS_JOB', -- tis is the first letter abbreviation of procedure name "t_ins_scheduler".
     job_type          => 'PLSQL_BLOCK',
     job_action        => 'begin t_ins; end;',
     start_date        => to_date('2019-07-26 11:00:00', 'yyyy-mm-dd hh24:mi:ss'),
     repeat_interval   => 'FREQ=MINUTELY; INTERVAL=2;',
     end_date          => to_date('2019-07-26 12:00:00', 'yyyy-mm-dd hh24:mi:ss'),
     auto_drop         => false,
     enabled           => true,
     job_class         => 'DEFAULT_JOB_CLASS',
     comments          => 'Regularly insert data to table t');
END;
/

===========================================================================================

SZD_BBS_V2@xxxx> create sequence t_id
2  start with    1
3  increment by  1
4  nocache
5  nocycle
6  ;

Sequence created.

SZD_BBS_V2@xxxx> create table t (id number, dt date);

Table created.

SZD_BBS_V2@xxxx> create or replace procedure t_ins
  2  is
  3  begin
  4    insert into t values (t_id.nextval, sysdate);
  5    commit;
  6  end;
  7  /

Procedure created.

SZD_BBS_V2@xxxx> create or replace procedure t_ins_scheduler
  2  is
  3  begin
  4    dbms_scheduler.create_job (
  5       job_name          => 'TIS_JOB', -- tis is the first letter abbreviation of procedure name "t_ins_scheduler".
  6       job_type          => 'PLSQL_BLOCK',
  7       job_action        => 'begin t_ins; end;',
  8       start_date        => to_date('2019-07-26 11:00:00', 'yyyy-mm-dd hh24:mi:ss'),
  9       repeat_interval   => 'FREQ=MINUTELY; INTERVAL=2;',
 10       end_date          => to_date('2019-07-26 12:00:00', 'yyyy-mm-dd hh24:mi:ss'),
 11       auto_drop         => false,
 12       enabled           => true,
 13       job_class         => 'DEFAULT_JOB_CLASS',
 14       comments          => 'Regularly insert data to table t');
 15  end;
 16  /

Procedure created.

SZD_BBS_V2@xxxx> exec t_ins_scheduler;

PL/SQL procedure successfully completed.

==========================================================================================

SZD_BBS_V2@xxxx> select log_id, log_date, owner, status from user_scheduler_job_log where job_name = 'TIS_JOB' order by 2;

    LOG_ID LOG_DATE                            OWNER        STATUS
---------- ----------------------------------- ------------ ------------
     89779 26-JUL-19 11.00.00.081517 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89780 26-JUL-19 11.02.00.046624 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89781 26-JUL-19 11.04.00.042969 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89782 26-JUL-19 11.06.00.039660 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89783 26-JUL-19 11.08.00.047067 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89784 26-JUL-19 11.10.00.041827 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89785 26-JUL-19 11.12.00.041492 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89786 26-JUL-19 11.14.00.038138 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89787 26-JUL-19 11.16.00.046941 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89788 26-JUL-19 11.18.00.042799 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89789 26-JUL-19 11.20.00.039643 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89790 26-JUL-19 11.22.00.035982 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89791 26-JUL-19 11.24.00.046050 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89792 26-JUL-19 11.26.00.044343 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89793 26-JUL-19 11.28.00.039554 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89795 26-JUL-19 11.30.00.046122 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89796 26-JUL-19 11.32.00.045379 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89797 26-JUL-19 11.34.00.044221 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89798 26-JUL-19 11.36.00.040311 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89799 26-JUL-19 11.38.00.037123 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89800 26-JUL-19 11.40.00.040919 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89801 26-JUL-19 11.42.00.038811 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89802 26-JUL-19 11.44.00.047691 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89803 26-JUL-19 11.46.00.045425 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89804 26-JUL-19 11.48.00.042618 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89806 26-JUL-19 11.50.00.016281 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89807 26-JUL-19 11.52.00.040431 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89808 26-JUL-19 11.54.00.047055 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89809 26-JUL-19 11.56.00.044316 AM +08:00 SZD_BBS_V2   SUCCEEDED
     89810 26-JUL-19 11.58.00.044189 AM +08:00 SZD_BBS_V2   SUCCEEDED

30 rows selected.

SZD_BBS_V2@xxxx> select start_date, job_creator, state, run_count, max_runs from user_scheduler_jobs where job_name = 'TIS_JOB';

START_DATE                             JOB_CREATOR  STATE        RUN_COUNT   MAX_RUNS
-------------------------------------- ------------ ----------- ---------- ----------
26-JUL-19 11.00.00.000000 AM +08:00    SZD_BBS_V2   COMPLETED           30


SZD_BBS_V2@xxxx> select * from t;

        ID DT
---------- -------------------
         1 2019-07-26 11:00:00
         2 2019-07-26 11:02:00
         3 2019-07-26 11:04:00
         4 2019-07-26 11:06:00
         5 2019-07-26 11:08:00
         6 2019-07-26 11:10:00
         7 2019-07-26 11:12:00
         8 2019-07-26 11:14:00
         9 2019-07-26 11:16:00
        10 2019-07-26 11:18:00
        11 2019-07-26 11:20:00
        12 2019-07-26 11:22:00
        13 2019-07-26 11:24:00
        14 2019-07-26 11:26:00
        15 2019-07-26 11:28:00
        16 2019-07-26 11:30:00
        17 2019-07-26 11:32:00
        18 2019-07-26 11:34:00
        19 2019-07-26 11:36:00
        20 2019-07-26 11:38:00
        21 2019-07-26 11:40:00
        22 2019-07-26 11:42:00
        23 2019-07-26 11:44:00
        24 2019-07-26 11:46:00
        25 2019-07-26 11:48:00
        26 2019-07-26 11:50:00
        27 2019-07-26 11:52:00
        28 2019-07-26 11:54:00
        29 2019-07-26 11:56:00
        30 2019-07-26 11:58:00

30 rows selected.
