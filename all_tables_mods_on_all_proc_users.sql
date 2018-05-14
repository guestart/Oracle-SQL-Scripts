REM
REM     Script:        all_tables_mods_on_all_proc_users.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 14, 2018
REM
REM     Purpose:  
REM       This sql script usually views information of modifications for all of tables on all of
REM       procduction users. These mods columns include "table_name", "inserts", "updates"
REM       "deletes", "timestamp", "truncated" and "drop_segments".
REM

SET LINESIZE 300
SET PAGESIZE 300

COLUMN table_owner FORMAT a20
COLUMN table_name  FORMAT a25
COLUMN truncated   FORMAT a5

SELECT table_owner
       , table_name
       , inserts
       , updates
       , deletes
       , timestamp
       , truncated
       , drop_segments
FROM dba_tab_modifications
WHERE table_owner NOT IN (
                          'ANONYMOUS'
                          , 'APEX_030200'
                          , 'APEX_PUBLIC_USER'
                          , 'APPQOSSYS'
                          , 'CTXSYS'
                          , 'DBSNMP'
                          , 'DIP'
                          , 'EXFSYS'
                          , 'FLOWS_FILES'
                          , 'MDDATA'
                          , 'MDSYS'
                          , 'MGMT_VIEW'
                          , 'OLAPSYS'
                          , 'ORACLE_OCM'
                          , 'ORDDATA'
                          , 'ORDPLUGINS'
                          , 'ORDSYS'
                          , 'OUTLN'
                          , 'OWBSYS'
                          , 'OWBSYS_AUDIT'
                          , 'SCOTT'
                          , 'SI_INFORMTN_SCHEMA'
                          , 'SPATIAL_CSW_ADMIN_USR'
                          , 'SPATIAL_WFS_ADMIN_USR'
                          , 'SQLTXADMIN'
                          , 'SQLTXPLAIN'
                          , 'SYS'
                          , 'SYSMAN'
                          , 'SYSTEM'
                          , 'WMSYS'
                          , 'XDB'
                          , 'XS$NULL'
                          )
AND table_name NOT LIKE 'BIN$%'
ORDER BY timestamp DESC
         , table_owner
         , table_name
;
