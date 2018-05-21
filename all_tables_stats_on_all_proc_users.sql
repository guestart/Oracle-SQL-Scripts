REM
REM     Script:        all_tables_stats_on_all_proc_users.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 14, 2018
REM
REM     Purpose:  
REM       This sql script usually views information of stats for all of tables on all of
REM       procduction users. These stats columns include "table_name", "num_rows", "blocks"
REM       "sample_size", "last_analyzed" and "stale_stats".
REM
REM     Modified:      May 21, 2018 - according to Jared Still (from Pythian, and his github is "https://github.com/jkstill")'s nice advice,  
REM                                   replace that manual list about all of the name of production user with simple SQL he has provided to me

SET LINESIZE 300
SET PAGESIZE 300

COLUMN owner       FORMAT a20
COLUMN table_name  FORMAT a35
COLUMN stale_stats FORMAT a11

SELECT owner
       , table_name
       , num_rows
       , blocks
       , sample_size
       , last_analyzed
       , stale_stats
FROM dba_tab_statistics
WHERE owner NOT IN (
--                    'ANONYMOUS'
--                    , 'APEX_030200'
--                    , 'APEX_PUBLIC_USER'
--                    , 'APPQOSSYS'
--                    , 'CTXSYS'
--                    , 'DBSNMP'
--                    , 'DIP'
--                    , 'EXFSYS'
--                    , 'FLOWS_FILES'
--                    , 'MDDATA'
--                    , 'MDSYS'
--                    , 'MGMT_VIEW'
--                    , 'OLAPSYS'
--                    , 'ORACLE_OCM'
--                    , 'ORDDATA'
--                    , 'ORDPLUGINS'
--                    , 'ORDSYS'
--                    , 'OUTLN'
--                    , 'OWBSYS'
--                    , 'OWBSYS_AUDIT'
--                    , 'SCOTT'
--                    , 'SI_INFORMTN_SCHEMA'
--                    , 'SPATIAL_CSW_ADMIN_USR'
--                    , 'SPATIAL_WFS_ADMIN_USR'
--                    , 'SQLTXADMIN'
--                    , 'SQLTXPLAIN'
--                    , 'SYS'
--                    , 'SYSMAN'
--                    , 'SYSTEM'
--                    , 'WMSYS'
--                    , 'XDB'
--                    , 'XS$NULL'
                      SELECT name schema_to_exclude
                      FROM system.LOGSTDBY$SKIP_SUPPORT
                      WHERE action = 0
                      ORDER BY schema_to_exclude
                   )
AND owner NOT IN (
                      'SQLTXADMIN'
                      , 'SQLTXPLAIN'
                 )
AND table_name NOT LIKE 'BIN$%'
ORDER BY owner
         , stale_stats DESC
         , last_analyzed DESC
         , table_name
;
