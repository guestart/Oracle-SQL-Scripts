REM
REM     Script:     monitor_big_table_size.sql
REM     Author:     Quanwen Zhao
REM     Dated:      May 25, 2021
REM
REM     Purpose:
REM         This SQL script focuses on monitoring the used size of big tables by using VIEW,
REM          PROCEDURE, SCHEDULER in the schema 'monitor'.
REM

CONN / AS SYSDBA

CREATE TABLESPACE monitor DATAFILE '/u01/oradata/prodb/monitor_01.dbf' SIZE 5g AUTOEXTEND ON NEXT 2g MAXSIZE 30g;
CREATE TEMPORARY TABLESPACE monitor_temp TEMPFILE '/u01/oradata/prodb/monitor_temp.dbf' SIZE 5g AUTOEXTEND ON NEXT 1g MAXSIZE 10g;

CREATE USER monitor IDENTIFIED BY monitor DEFAULT TABLESAPCE monitor QUOTA 5g ON monitor TEMPORARY TABLESPACE monitor_temp;

GRAMT connect, resource TO monitor;
GRANT create view TO monitor;
GRANT create job TO monitor;

CONN monitor/monitor

CREATE OR REPLACE VIEW get_used_size_of_big_table AS
WITH 
   ds AS (SELECT owner
               , segment_name
               , SUM(bytes)/POWER(2, 20) AS used_mb
            FROM dba_segments
           WHERE owner = UPPER('&&owner_name')
             AND segment_type = 'TABLE'     
           GROUP BY owner
                  , segment_name
          HAVING SUM(bytes)/POWER(2, 20) > 1024
           ORDER BY segment_name
         ),
   dt AS (SELECT owner
               , table_name
               , num_rows
               , blocks
            -- , empty_blocks
            -- , avg_space
               , avg_row_len
            FROM dba_tables
           WHERE owner = UPPER('&owner_name')
           ORDER BY table_name
         )
SELECT dt.owner
     , dt.table_name
     , ds.used_mb
     , dt.num_rows
     , dt.blocks
  -- , dt.empty_blocks
  -- , dt.avg_space
     , dt.avg_row_len
  FROM ds, dt
 WHERE ds.owner = dt.owner
   AND ds.segment_name = dt.table_name
 ORDER BY ds.used_mb DESC
        , dt.num_rows DESC
        , dt.table_name
;

CREATE TABLE big_table_info (
  owner_name  varchar2(30) not null,
  table_name  varchar2(30) constraint bti_pk primary key,
  used_mb     number       not null,
  num_rows    number,
  blocks      number,
  avg_row_len number,
  insert_time date default SYSDATE not null 
);

ALTER SESSION SET nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

CREATE OR REPLACE PROCEDURE insert_big_table AS
BEGIN
  INSERT INTO big_table_info (owner_name, table_name, used_mb, num_rows, blocks, avg_row_len)
  SELECT * FROM get_used_size_of_big_table;
  COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE insert_big_table_scheduler
IS
BEGIN
  DBMS_SCHEDULER.create_job (
     job_name          => 'INSERT_BIG_TABLE_JOB',
     job_type          => 'STORED_PROCEDURE',
     job_action        => 'MONITOR.INSERT_BIG_TABLE',
     start_date        => to_date('2021-05-25 19:30:00', 'yyyy-mm-dd hh24:mi:ss'),
     repeat_interval   => 'FREQ=DAILY; INTERVAL=2;',
  -- end_date          => to_date('2021-07-25 19:30:00', 'yyyy-mm-dd hh24:mi:ss'),
     auto_drop         => false,
     enabled           => true,
     job_class         => 'DEFAULT_JOB_CLASS',
     comments          => 'Regularly insert data to table big_table_info');
END;
/

EXEC insert_big_table_scheduler;

COLUMN job_name        FORMAT a20
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
  -- , job_action
  -- , start_date
     , repeat_interval
  -- , end_date
  -- , auto_drop
  -- , enabled
     , job_class
  -- , comments
     , state
     , run_count
     , max_runs
FROM user_scheduler_jobs
;

COLUMN job_name  FORMAT a20
COLUMN owner     FORMAT a12
COLUMN log_date  FORMAT a35
COLUMN job_class FORMAT a17
COLUMN operation FORMAT a9
COLUMN status    FORMAT a9

SELECT job_name
     , owner
     , log_id
     , log_date
     , job_class
     , operation
     , status
FROM user_scheduler_job_log
ORDER BY log_date
/

SET LINESIZE 150
SET PAGESIZE 300

COLUMN owner      FORMAT a30
COLUMN table_name FORMAT a30

SELECT * FROM get_used_size_of_big_table;

COLUMN owner_name FORMAT a30
COLUMN table_name FORMAT a30

SELECT * FROM big_table_info;
