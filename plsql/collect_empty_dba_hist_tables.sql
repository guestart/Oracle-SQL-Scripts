REM
REM     Script:        collect_empty_dba_hist_tables.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Dec 11, 2021
REM
REM     Last tested:
REM             11.2.0.4
REM             19.3.0.0
REM             19.12.0.0
REM             21.3.0.0
REM
REM    Referenes:
REM      https://gist.github.com/guestart/1e0f49089530564a9f7c01b015416ad7
REM      https://gist.github.com/guestart/0ca72e5344aa3ecaf26b905337e1dcd8
REM

-- begin
--   dbms_output.put_line('All of the DBA_HIST tables that returned to 0 line are as follows:' || chr(10));
-- end;
-- /
-- All of the DBA_HIST tables that returned to 0 line are as follows:
-- 
-- 
-- 
-- PL/SQL procedure successfully completed.
-- 
-- begin
--   dbms_output.put_line('All of the DBA_HIST tables that returned to 0 line are as follows:' || chr(13));
-- end;
-- /
-- All of the DBA_HIST tables that returned to 0 line are as follows:
-- 
-- PL/SQL procedure successfully completed.

PROMPT ==================================================
PROMPT  Using explicit cursor and dynamic SQL to collect
PROMPT ==================================================

SET SERVEROUTPUT ON;
SET FEEDBACK OFF;

DECLARE
  v_sql    VARCHAR2(200);
  tab_rows NUMBER;
  tab_nums NUMBER;
  CURSOR cur_dba_hist IS
  SELECT table_name
  FROM dict
  WHERE table_name LIKE '%DBA_HIST_%'
  ORDER BY 1;
BEGIN
  DBMS_OUTPUT.PUT_LINE(CHR(13));
  DBMS_OUTPUT.PUT_LINE('All of the "DBA_HIST_" tables that returned 0 line are as follows:');
  DBMS_OUTPUT.PUT_LINE(CHR(13));
  
  tab_nums := 0;
  
  FOR v_dba_hist IN cur_dba_hist
  LOOP
    v_sql := 'SELECT COUNT(*) FROM ' || v_dba_hist.table_name;
    EXECUTE IMMEDIATE v_sql INTO tab_rows;
    IF tab_rows = 0 THEN
      tab_nums := tab_nums + 1;
      DBMS_OUTPUT.PUT_LINE(v_dba_hist.table_name);
    END IF;
  END LOOP;
  
  DBMS_OUTPUT.PUT_LINE(CHR(13));
  DBMS_OUTPUT.PUT_LINE('Total number of "DBA_HIST_" tables that returned 0 line is: ' || tab_nums || '.');
  DBMS_OUTPUT.PUT_LINE(CHR(13));
END;
/

PROMPT =============================================
PROMPT  Using REF cursor and dynamic SQL to collect
PROMPT =============================================

SET SERVEROUTPUT ON;
SET FEEDBACK OFF;

DECLARE
  v_sql        VARCHAR2(200);
  v_tablename  VARCHAR2(50);
  tab_rows     NUMBER;
  tab_nums     NUMBER;
  v_ref_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_ref_cursor FOR
  SELECT table_name
  FROM dict
  WHERE table_name LIKE '%DBA_HIST_%'
  ORDER BY 1;
  
  DBMS_OUTPUT.PUT_LINE(CHR(13));
  DBMS_OUTPUT.PUT_LINE('All of the "DBA_HIST_" tables that returned 0 line are as follows:');
  DBMS_OUTPUT.PUT_LINE(CHR(13));
  
  tab_nums := 0;
  
  LOOP
    FETCH v_ref_cursor INTO v_tablename;
    v_sql := 'SELECT COUNT(*) FROM ' || v_tablename;
    EXECUTE IMMEDIATE v_sql INTO tab_rows;
    IF tab_rows = 0 THEN
      tab_nums := tab_nums + 1;
      DBMS_OUTPUT.PUT_LINE(v_tablename);
    END IF;
    EXIT WHEN v_ref_cursor%NOTFOUND;
  END LOOP;
  
  CLOSE v_ref_cursor;
  
  DBMS_OUTPUT.PUT_LINE(CHR(13));
  DBMS_OUTPUT.PUT_LINE('Total number of "DBA_HIST_" tables that returned 0 line is: ' || tab_nums || '.');
  DBMS_OUTPUT.PUT_LINE(CHR(13));
END;
/

-- When you run the previous two types of anonymous pl/sql code blocks you'll get the following output result.

-- Running on 11.2.0.4, shown 24 number of "DBA_HIST_" tables.

All of the "DBA_HIST_" tables that returned 0 line are as follows:

DBA_HIST_BASELINE_TEMPLATE
DBA_HIST_CLUSTER_INTERCON
DBA_HIST_COLORED_SQL
DBA_HIST_CR_BLOCK_SERVER
DBA_HIST_CURRENT_BLOCK_SERVER
DBA_HIST_DLM_MISC
DBA_HIST_DYN_REMASTER_STATS
DBA_HIST_FILEMETRIC_HISTORY
DBA_HIST_IC_CLIENT_STATS
DBA_HIST_IC_DEVICE_STATS
DBA_HIST_INST_CACHE_TRANSFER
DBA_HIST_INTERCONNECT_PINGS
DBA_HIST_LATCH_CHILDREN
DBA_HIST_LATCH_PARENT
DBA_HIST_MEMORY_RESIZE_OPS
DBA_HIST_MEMORY_TARGET_ADVICE
DBA_HIST_MTTR_TARGET_ADVICE
DBA_HIST_PERSISTENT_QUEUES
DBA_HIST_PERSISTENT_SUBS
DBA_HIST_SESSMETRIC_HISTORY
DBA_HIST_SNAP_ERROR
DBA_HIST_STREAMS_APPLY_SUM
DBA_HIST_STREAMS_CAPTURE
DBA_HIST_WAITCLASSMET_HISTORY

Total number of "DBA_HIST_" tables that returned 0 line is: 24

-- Running on 19.3, shown 53 number of "DBA_HIST_" tables.

All of the "DBA_HIST_" tables that returned 0 line are as follows:

DBA_HIST_APPLY_SUMMARY
DBA_HIST_ASM_BAD_DISK
DBA_HIST_ASM_DISKGROUP
DBA_HIST_ASM_DISKGROUP_STAT
DBA_HIST_ASM_DISK_STAT_SUMMARY
DBA_HIST_BASELINE_TEMPLATE
DBA_HIST_BUFFERED_QUEUES
DBA_HIST_BUFFERED_SUBSCRIBERS
DBA_HIST_CAPTURE
DBA_HIST_CELL_CONFIG
DBA_HIST_CELL_CONFIG_DETAIL
DBA_HIST_CELL_DB
DBA_HIST_CELL_DISKTYPE
DBA_HIST_CELL_DISK_NAME
DBA_HIST_CELL_DISK_SUMMARY
DBA_HIST_CELL_GLOBAL
DBA_HIST_CELL_GLOBAL_SUMMARY
DBA_HIST_CELL_IOREASON
DBA_HIST_CELL_NAME
DBA_HIST_CELL_OPEN_ALERTS
DBA_HIST_CLUSTER_INTERCON
DBA_HIST_COLORED_SQL
DBA_HIST_COMP_IOSTAT
DBA_HIST_CON_SYSMETRIC_HIST
DBA_HIST_CR_BLOCK_SERVER
DBA_HIST_CURRENT_BLOCK_SERVER
DBA_HIST_DLM_MISC
DBA_HIST_DYN_REMASTER_STATS
DBA_HIST_FILEMETRIC_HISTORY
DBA_HIST_FILESTATXS
DBA_HIST_IC_CLIENT_STATS
DBA_HIST_IC_DEVICE_STATS
DBA_HIST_IM_SEG_STAT
DBA_HIST_INST_CACHE_TRANSFER
DBA_HIST_INTERCONNECT_PINGS
DBA_HIST_JAVA_POOL_ADVICE
DBA_HIST_LATCH_CHILDREN
DBA_HIST_LATCH_PARENT
DBA_HIST_LMS_STATS
DBA_HIST_MEMORY_RESIZE_OPS
DBA_HIST_MEMORY_TARGET_ADVICE
DBA_HIST_MTTR_TARGET_ADVICE
DBA_HIST_RECOVERY_PROGRESS
DBA_HIST_REPLICATION_TBL_STATS
DBA_HIST_REPLICATION_TXN_STATS
DBA_HIST_SESSMETRIC_HISTORY
DBA_HIST_SESS_SGA_STATS
DBA_HIST_SNAP_ERROR
DBA_HIST_STREAMS_APPLY_SUM
DBA_HIST_STREAMS_CAPTURE
DBA_HIST_TEMPFILE
DBA_HIST_TEMPSTATXS
DBA_HIST_WAITCLASSMET_HISTORY

Total number of "DBA_HIST_" tables that returned 0 line is: 53.

-- Running on 19.12, shown 58 number of "DBA_HIST_" tables.

All of the "DBA_HIST_" tables that returned 0 line are as follows:

DBA_HIST_APPLY_SUMMARY
DBA_HIST_ASM_BAD_DISK
DBA_HIST_ASM_DISKGROUP
DBA_HIST_ASM_DISKGROUP_STAT
DBA_HIST_ASM_DISK_STAT_SUMMARY
DBA_HIST_BASELINE_TEMPLATE
DBA_HIST_BUFFERED_QUEUES
DBA_HIST_BUFFERED_SUBSCRIBERS
DBA_HIST_CAPTURE
DBA_HIST_CELL_CONFIG
DBA_HIST_CELL_CONFIG_DETAIL
DBA_HIST_CELL_DB
DBA_HIST_CELL_DISKTYPE
DBA_HIST_CELL_DISK_NAME
DBA_HIST_CELL_DISK_SUMMARY
DBA_HIST_CELL_GLOBAL
DBA_HIST_CELL_GLOBAL_SUMMARY
DBA_HIST_CELL_IOREASON
DBA_HIST_CELL_NAME
DBA_HIST_CELL_OPEN_ALERTS
DBA_HIST_CLUSTER_INTERCON
DBA_HIST_COLORED_SQL
DBA_HIST_COMP_IOSTAT
DBA_HIST_CON_SYSMETRIC_HIST
DBA_HIST_CR_BLOCK_SERVER
DBA_HIST_CURRENT_BLOCK_SERVER
DBA_HIST_DLM_MISC
DBA_HIST_DYN_REMASTER_STATS
DBA_HIST_FILEMETRIC_HISTORY
DBA_HIST_FILESTATXS
DBA_HIST_IC_CLIENT_STATS
DBA_HIST_IC_DEVICE_STATS
DBA_HIST_IM_SEG_STAT
DBA_HIST_INST_CACHE_TRANSFER
DBA_HIST_INTERCONNECT_PINGS
DBA_HIST_LATCH_CHILDREN
DBA_HIST_LATCH_PARENT
DBA_HIST_LMS_STATS
DBA_HIST_MEMORY_RESIZE_OPS
DBA_HIST_MEMORY_TARGET_ADVICE
DBA_HIST_MTTR_TARGET_ADVICE
DBA_HIST_PERSISTENT_QMN_CACHE
DBA_HIST_PERSISTENT_QUEUES
DBA_HIST_PERSISTENT_SUBS
DBA_HIST_RECOVERY_PROGRESS
DBA_HIST_REPLICATION_TBL_STATS
DBA_HIST_REPLICATION_TXN_STATS
DBA_HIST_RULE_SET
DBA_HIST_SESSMETRIC_HISTORY
DBA_HIST_SESS_SGA_STATS
DBA_HIST_SESS_TIME_STATS
DBA_HIST_SNAP_ERROR
DBA_HIST_STREAMS_APPLY_SUM
DBA_HIST_STREAMS_CAPTURE
DBA_HIST_STREAMS_POOL_ADVICE
DBA_HIST_TEMPFILE
DBA_HIST_TEMPSTATXS
DBA_HIST_WAITCLASSMET_HISTORY

Total number of "DBA_HIST_" tables that returned 0 line is: 58.

-- Running on 21.3, shown 60 number of "DBA_HIST_" tables.

All of the "DBA_HIST_" tables that returned 0 line are as follows:

DBA_HIST_APPLY_SUMMARY
DBA_HIST_ASM_BAD_DISK
DBA_HIST_ASM_DISKGROUP
DBA_HIST_ASM_DISKGROUP_STAT
DBA_HIST_ASM_DISK_STAT_SUMMARY
DBA_HIST_BASELINE_TEMPLATE
DBA_HIST_BUFFERED_QUEUES
DBA_HIST_BUFFERED_SUBSCRIBERS
DBA_HIST_CAPTURE
DBA_HIST_CELL_CONFIG
DBA_HIST_CELL_CONFIG_DETAIL
DBA_HIST_CELL_DB
DBA_HIST_CELL_DISKTYPE
DBA_HIST_CELL_DISK_NAME
DBA_HIST_CELL_DISK_SUMMARY
DBA_HIST_CELL_GLOBAL
DBA_HIST_CELL_GLOBAL_SUMMARY
DBA_HIST_CELL_IOREASON
DBA_HIST_CELL_NAME
DBA_HIST_CELL_OPEN_ALERTS
DBA_HIST_CLUSTER_INTERCON
DBA_HIST_COLORED_SQL
DBA_HIST_COMP_IOSTAT
DBA_HIST_CON_SYSMETRIC_HIST
DBA_HIST_CR_BLOCK_SERVER
DBA_HIST_CURRENT_BLOCK_SERVER
DBA_HIST_DLM_MISC
DBA_HIST_DYN_REMASTER_STATS
DBA_HIST_FILEMETRIC_HISTORY
DBA_HIST_FILESTATXS
DBA_HIST_IC_CLIENT_STATS
DBA_HIST_IC_DEVICE_STATS
DBA_HIST_IM_SEG_STAT
DBA_HIST_INST_CACHE_TRANSFER
DBA_HIST_INTERCONNECT_PINGS
DBA_HIST_JAVA_POOL_ADVICE
DBA_HIST_LATCH_CHILDREN
DBA_HIST_LATCH_PARENT
DBA_HIST_LMS_STATS
DBA_HIST_MEMORY_RESIZE_OPS
DBA_HIST_MEMORY_TARGET_ADVICE
DBA_HIST_MTTR_TARGET_ADVICE
DBA_HIST_PERSISTENT_QMN_CACHE
DBA_HIST_PERSISTENT_QUEUES
DBA_HIST_PERSISTENT_SUBS
DBA_HIST_RECOVERY_PROGRESS
DBA_HIST_REPLICATION_TBL_STATS
DBA_HIST_REPLICATION_TXN_STATS
DBA_HIST_RULE_SET
DBA_HIST_SESSMETRIC_HISTORY
DBA_HIST_SESS_NETWORK
DBA_HIST_SESS_SGA_STATS
DBA_HIST_SESS_TIME_STATS
DBA_HIST_SNAP_ERROR
DBA_HIST_STREAMS_APPLY_SUM
DBA_HIST_STREAMS_CAPTURE
DBA_HIST_STREAMS_POOL_ADVICE
DBA_HIST_TEMPFILE
DBA_HIST_TEMPSTATXS
DBA_HIST_WAITCLASSMET_HISTORY

Total number of "DBA_HIST_" tables that returned 0 line is: 60.
