-- +----------------------------------------------------------------------------+
-- |                                 Quanwen Zhao                               |
-- |                               guestart@163.com                             |
-- |                          quanwenzhao.wordpress.com                         |
-- |----------------------------------------------------------------------------|
-- |         Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.         |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : switch_redo_log_for_recycle.sql                                 |
-- | CLASS    : Administration                                                  |
-- | PURPOSE  : Switch all of online redo log for a recycle on oracle database. |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET ECHO      OFF
SET FEEDBACK  OFF
SET HEADING   ON
SET LINESIZE  300
SET PAGESIZE  300
SET TERMOUT   ON
SET TIMING    OFF
SET TRIMOUT   ON
SET TRIMSPOOL ON
SET VERIFY    OFF

SET SERVEROUTPUT ON;

DECLARE
  nums         NUMBER;
  str_exec_sql VARCHAR2(512);
BEGIN
  SELECT COUNT(group#) INTO nums FROM v$log;
  str_exec_sql := 'alter system archive log current';
  FOR num IN 1 .. nums
  LOOP
    EXECUTE IMMEDIATE str_exec_sql;
  END LOOP;
END;
/
