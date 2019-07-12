REM
REM     Script:    expdp_exclude_stats.sql
REM     Author:    Quanwen Zhao
REM     Dated:     Jul 11, 2019
REM
REM     Purpose:
REM         This SQL script uses to simulate the circumstance of adding this parameter "statistics=none"
REM         or "exclude=statistics" at the end of a usual EXPDP command.
REM

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CREATE TABLESPACE test DATAFILE '/u01/app/oracle/oradata/test/test01.dbf' SIZE 100m;

CREATE USER test IDENTIFIED BY test DEFAULT TABLESPACE test;

GRANT connect, resource TO test;

PROMPT ==========================
PROMPT Executing on "TEST" schema
PROMPT ==========================

CONN test/test;

CREATE TABLE t1 AS SELECT * FROM all_objects;

INSERT INTO t1 SELECT * FROM t1;

INSERT INTO t1 SELECT * FROM t1;

INSERT INTO t1 SELECT * FROM t1;

INSERT INTO t1 SELECT * FROM t1;

-- At this very moment showing this error, ORA-01653: unable to extend table TEST.T1 by 1024 in tablespace TEST

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;

ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/test/test01.dbf' AUTOEXTEND ON NEXT 50m MAXSIZE 500m;

-- As you can also see from "/u01/app/oracle/diag/rdbms/test/test/trace/alert_test.log"
-- ......
-- Wed Jul 10 10:06:44 2019
-- create tablespace test datafile '/u01/app/oracle/oradata/test/test01.dbf' size 100m
-- Completed: create tablespace test datafile '/u01/app/oracle/oradata/test/test01.dbf' size 100m
-- Wed Jul 10 10:09:36 2019
-- ORA-1653: unable to extend table TEST.T1 by 1024 in                 tablespace TEST
-- Wed Jul 10 11:02:23 2019
-- alter database datafile '/u01/app/oracle/oradata/test/test01.dbf' autoextend on next 50m maxsize 500m
-- Completed: alter database datafile '/u01/app/oracle/oradata/test/test01.dbf' autoextend on next 50m maxsize 500m

PROMPT ==========================
PROMPT Executing on "TEST" schema
PROMPT ==========================

CONN test/test;

INSERT INTO t1 SELECT * FROM t1;

COMMIT;

SELECT COUNT(*) FROM t1;

CREATE TABLE t2 AS SELECT * FROM all_tables;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

INSERT INTO t2 SELECT * FROM t2;

COMMIT;

SELECT COUNT(*) FROM t2;

-- Comparing before and after gathering tab statistics of table "T1" and "T2".

SELECT num_rows, last_analyzed FROM user_tables WHERE table_name IN ('T1', 'T2');

EXEC DBMS_STATS.gather_table_stats(OWNNAME => 'TEST', TABNAME => 'T1');

EXEC DBMS_STATS.gather_table_stats(OWNNAME => 'TEST', TABNAME => 'T2');

SELECT num_rows, last_analyzed FROM user_tables WHERE table_name IN ('T1', 'T2');

-- Comparing before and after gathering index statistics of table "T1" and "T2".

CREATE INDEX idx_object_name ON t1 (object_name);

CREATE INDEX idx_table_name ON t2 (table_name);

SELECT num_rows, last_analyzed FROM user_indexes WHERE table_name IN ('T1', 'T2');

EXEC DBMS_STATS.gather_index_stats(OWNNAME => 'TEST', INDNAME => 'idx_object_name');

EXEC DBMS_STATS.gather_index_stats(OWNNAME => 'TEST', INDNAME => 'idx_table_name');

SELECT num_rows, last_analyzed FROM user_indexes WHERE table_name IN ('T1', 'T2');

PROMPT =========================
PROMPT Executing on "SYS" schema
PROMPT =========================

CONN / as sysdba;

CREATE OR REPLACE DIRECTORY expdp AS '/u01/app/oracle/expdp';

GRANT read, write ON DIRECTORY expdp TO test;

PROMPT ========================================================
PROMPT
PROMPT Executing expdp command on OS prompt "[oracle@xxxx ~]$ "
PROMPT
PROMPT via adding parameter "statistics=none"
PROMPT
PROMPT ========================================================

HOST expdp test/test tables=t1, t2 directory=expdp dumpfile=expdp_t1t2_`date +%Y%m%d%H%M%S`.dmp logfile=expdp_t1t2_`date +%Y%m%d%H%M%S`.log statistics=none
-- 
-- Export: Release 11.2.0.4.0 - Production on Fri Jul 11 11:00:48 2019
-- 
-- Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.
-- 
-- Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
-- With the Partitioning, Oracle Label Security, OLAP, Data Mining,
-- Oracle Database Vault and Real Application Testing options
-- Legacy Mode Active due to the following parameters:
-- Legacy Mode Parameter: "statistics=none" Location: Command Line, ignored.
-- Legacy Mode has set reuse_dumpfiles=true parameter.
-- Starting "TEST"."SYS_EXPORT_TABLE_01":  test/******** tables=t1, t2 directory=expdp dumpfile=expdp_t1t2_20190711110048.dmp logfile=expdp_t1t2_20190711110048.log reuse_dumpfiles=true 
-- Estimate in progress using BLOCKS method...
-- Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
-- Total estimation using BLOCKS method: 111 MB
-- Processing object type TABLE_EXPORT/TABLE/TABLE
-- Processing object type TABLE_EXPORT/TABLE/INDEX/INDEX
-- Processing object type TABLE_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
-- Processing object type TABLE_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
-- . . exported "TEST"."T1"                                 53.54 MB  546464 rows
-- . . exported "TEST"."T2"                                 12.28 MB   53248 rows
-- Master table "TEST"."SYS_EXPORT_TABLE_01" successfully loaded/unloaded
-- ******************************************************************************
-- Dump file set for TEST.SYS_EXPORT_TABLE_01 is:
-- /u01/app/oracle/expdp/expdp_t1t2_20190712110048.dmp
-- Job "TEST"."SYS_EXPORT_TABLE_01" successfully completed at Fri Jul 11 11:00:53 2019 elapsed 0 00:00:04

PROMPT ========================================================
PROMPT
PROMPT Executing expdp command on OS prompt "[oracle@xxxx ~]$ "
PROMPT
PROMPT via adding parameter "exclude=statistics"
PROMPT
PROMPT ========================================================

HOST expdp test/test tables=t1, t2 directory=expdp dumpfile=expdp_t1t2_`date +%Y%m%d%H%M%S`.dmp logfile=expdp_t1t2_`date +%Y%m%d%H%M%S`.log exclude=statistics

-- Export: Release 11.2.0.4.0 - Production on Fri Jul 11 11:01:05 2019
-- 
-- Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.
-- 
-- Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
-- With the Partitioning, Oracle Label Security, OLAP, Data Mining,
-- Oracle Database Vault and Real Application Testing options
-- Starting "TEST"."SYS_EXPORT_TABLE_01":  test/******** tables=t1, t2 directory=expdp dumpfile=expdp_t1t2_20190711110104.dmp logfile=expdp_t1t2_20190711110104.log exclude=statistics 
-- Estimate in progress using BLOCKS method...
-- Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
-- Total estimation using BLOCKS method: 111 MB
-- Processing object type TABLE_EXPORT/TABLE/TABLE
-- Processing object type TABLE_EXPORT/TABLE/INDEX/INDEX
-- . . exported "TEST"."T1"                                 53.54 MB  546464 rows
-- . . exported "TEST"."T2"                                 12.28 MB   53248 rows
-- Master table "TEST"."SYS_EXPORT_TABLE_01" successfully loaded/unloaded
-- ******************************************************************************
-- Dump file set for TEST.SYS_EXPORT_TABLE_01 is:
-- /u01/app/oracle/expdp/expdp_t1t2_20190712110104.dmp
-- Job "TEST"."SYS_EXPORT_TABLE_01" successfully completed at Fri Jul 11 11:01:09 2019 elapsed 0 00:00:04
