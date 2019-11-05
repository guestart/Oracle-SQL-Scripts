REM
REM     Script:        tablespace_non-temp_compare_total_size_simple_version.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 05, 2019
REM
REM     Notice:
REM       The following contents introduce the real source of these 3 views "sys.sm$ts_avail", "sys.sm$ts_used" and "sys.sm$ts_free".
REM
REM       SQL> DESC dba_views
REM
REM             Name                                      Null?    Type
REM             ----------------------------------------- -------- ----------------------------
REM             OWNER                                     NOT NULL VARCHAR2(30)
REM             VIEW_NAME                                 NOT NULL VARCHAR2(30)
REM             TEXT_LENGTH                                        NUMBER
REM             TEXT                                               LONG
REM             TYPE_TEXT_LENGTH                                   NUMBER
REM             TYPE_TEXT                                          VARCHAR2(4000)
REM             OID_TEXT_LENGTH                                    NUMBER
REM             OID_TEXT                                           VARCHAR2(4000)
REM             VIEW_TYPE_OWNER                                    VARCHAR2(30)
REM             VIEW_TYPE                                          VARCHAR2(30)
REM             SUPERVIEW_NAME                                     VARCHAR2(30)
REM             EDITIONING_VIEW                                    VARCHAR2(1)
REM             READ_ONLY                                          VARCHAR2(1)
REM
REM       SQL> SET LONG 1000000000
REM
REM       SQL> SELECT text FROM dba_views WHERE view_name = UPPER ('sm$ts_avail');
REM
REM       TEXT
REM       --------------------------------------------------------------------------------
REM       select tablespace_name, sum(bytes) bytes from dba_data_files
REM           group by tablespace_name
REM
REM       SQL> SELECT text FROM dba_views WHERE view_name = UPPER ('sm$ts_used');
REM
REM       TEXT
REM       --------------------------------------------------------------------------------
REM       select tablespace_name, sum(bytes) bytes from dba_segments
REM           group by tablespace_name
REM
REM       SQL> SELECT text FROM dba_views WHERE view_name = UPPER ('sm$ts_free');
REM
REM       TEXT
REM       --------------------------------------------------------------------------------
REM       select tablespace_name, sum(bytes) bytes from dba_free_space
REM           group by tablespace_name
REM
REM     Purpose:  
REM       This SQL script usually uses to compare the difference about total size (using simple version) of
REM       all of the non-temp tablespaces on Oracle Database.
REM

SET LINESIZE 1000
SET PAGESIZE 1000

COLUMN ts_name    FORMAT a25
COLUMN total_mb   FORMAT 999,999,999.99
COLUMN total_mb_2 FORMAT 999,999,999.99

SELECT a.tablespace_name AS ts_name
       , a.bytes/1024/1024 AS total_mb
       , (b.bytes + c.bytes)/1024/1024 AS total_mb_2
       , (a.bytes - (b.bytes + c.bytes))/1024/1024 AS diff
FROM sys.sm$ts_avail a
     , sys.sm$ts_used b
     , sys.sm$ts_free c
WHERE a.tablespace_name = b.tablespace_name
AND   a.tablespace_name = c.tablespace_name
ORDER BY 1,4
;

-- TS_NAME                          TOTAL_MB      TOTAL_MB_2       DIFF
-- ------------------------- --------------- --------------- ----------
-- SYSAUX                         107,898.00      107,894.38      3.625
-- SYSTEM                         139,196.00      139,191.00          5
-- WWW_XXXXXXXXXXX                638,538.00      644,617.06 -6079.0625
-- WWW_YYYYYYYYYYY                  4,096.00        4,105.00         -9
-- UNDOTBS1                        25,845.00       25,844.00          1
-- USERS                            2,758.00        2,757.00          1
-- 
-- 6 rows selected.
