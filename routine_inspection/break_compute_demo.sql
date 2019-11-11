REM
REM     Script:        break_compute_demo.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 11, 2019
REM
REM     Purpose:  
REM       This SQL script usually uses to break (SQL*Plus command) tablespace_name and compute (SQL*Plus command)
REM       dropped size based on recyclebin object "BIN$..." existing in Oracle Static Data Dictionary View "dba_segments".
REM

SET LINESIZE 1000
SET PAGESIZE 1000

BREAK ON ts_name SKIP 1
COMPUTE SUM OF dropped_mb ON ts_name

COLUMN ts_name    FORMAT a25
COLUMN sg_name    FORMAT a30
COLUMN dropped_mb FORMAT 999,999,999.9999

SELECT tablespace_name AS ts_name
       , segment_name AS sg_name
       , SUM(bytes)/1024/1024 AS dropped_mb
FROM dba_segments
WHERE segment_name LIKE 'BIN$%'
GROUP BY tablespace_name, segment_name
ORDER BY 1, 2
/

-- TS_NAME                   SG_NAME                               DROPPED_MB
-- ------------------------- ------------------------------ -----------------
-- SYSAUX                    BIN$Mg+kVZJF6x/gUxwAZQoWpw==$0             .1875
--                           BIN$Mg+kVZJG6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJH6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJI6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJJ6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJK6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJL6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJM6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJN6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Ne0yO3q0q4bgUxwAZQo/Nw==$0             .1875
--                           BIN$Ne0yO3q1q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q2q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q3q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q4q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q5q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q6q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q7q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q8q4bgUxwAZQo/Nw==$0             .0625
-- *************************                                -----------------
-- sum                                                                 1.3750
-- 
-- WWW_XXXXXXXXXXX           BIN$S3VonPzfEwHgUxwAZQpddw==$0            4.0000
--                           BIN$S3VonPzkEwHgUxwAZQpddw==$0            4.0000
--                           BIN$jbOtu8fCIXrgUxwAZQoTtg==$0        2,958.0000
--                           BIN$jbOtu8fDIXrgUxwAZQoTtg==$0          232.0000
--                           BIN$jbOtu8fEIXrgUxwAZQoTtg==$0          976.0000
--                           BIN$jbOtu8fFIXrgUxwAZQoTtg==$0        1,216.0000
--                           BIN$jbOtu8fGIXrgUxwAZQoTtg==$0          128.0000
--                           BIN$jbOtu8fHIXrgUxwAZQoTtg==$0          192.0000
--                           BIN$je2SMUSfr6TgUxwAZQqyLQ==$0           61.0000
--                           BIN$je2SMUSgr6TgUxwAZQqyLQ==$0          336.0000
--                           BIN$lWKwh7pwJSngUxwAZQoxFQ==$0             .0625
-- *************************                                -----------------
-- sum                                                             6,107.0625
-- 
-- WWW_YYYYYYYYYYY           BIN$S3VonPyYEwHgUxwAZQpddw==$0           10.0000
-- *************************                                -----------------
-- sum                                                                10.0000
-- 
-- 
-- 30 rows selected.

SET LINESIZE 1000
SET PAGESIZE 1000

BREAK ON ts_name SKIP PAGE
COMPUTE SUM OF dropped_mb ON ts_name

COLUMN ts_name    FORMAT a25
COLUMN sg_name    FORMAT a30
COLUMN dropped_mb FORMAT 999,999,999.9999

SELECT tablespace_name AS ts_name
       , segment_name AS sg_name
       , SUM(bytes)/1024/1024 AS dropped_mb
FROM dba_segments
WHERE segment_name LIKE 'BIN$%'
GROUP BY tablespace_name, segment_name
ORDER BY 1, 2
/

-- TS_NAME                   SG_NAME                               DROPPED_MB
-- ------------------------- ------------------------------ -----------------
-- SYSAUX                    BIN$Mg+kVZJF6x/gUxwAZQoWpw==$0             .1875
--                           BIN$Mg+kVZJG6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJH6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJI6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJJ6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJK6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJL6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJM6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJN6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Ne0yO3q0q4bgUxwAZQo/Nw==$0             .1875
--                           BIN$Ne0yO3q1q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q2q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q3q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q4q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q5q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q6q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q7q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q8q4bgUxwAZQo/Nw==$0             .0625
-- *************************                                -----------------
-- sum                                                                 1.3750
-- 
-- TS_NAME                   SG_NAME                               DROPPED_MB
-- ------------------------- ------------------------------ -----------------
-- WWW_XXXXXXXXXXX           BIN$S3VonPzfEwHgUxwAZQpddw==$0            4.0000
--                           BIN$S3VonPzkEwHgUxwAZQpddw==$0            4.0000
--                           BIN$jbOtu8fCIXrgUxwAZQoTtg==$0        2,958.0000
--                           BIN$jbOtu8fDIXrgUxwAZQoTtg==$0          232.0000
--                           BIN$jbOtu8fEIXrgUxwAZQoTtg==$0          976.0000
--                           BIN$jbOtu8fFIXrgUxwAZQoTtg==$0        1,216.0000
--                           BIN$jbOtu8fGIXrgUxwAZQoTtg==$0          128.0000
--                           BIN$jbOtu8fHIXrgUxwAZQoTtg==$0          192.0000
--                           BIN$je2SMUSfr6TgUxwAZQqyLQ==$0           61.0000
--                           BIN$je2SMUSgr6TgUxwAZQqyLQ==$0          336.0000
--                           BIN$lWKwh7pwJSngUxwAZQoxFQ==$0             .0625
-- *************************                                -----------------
-- sum                                                             6,107.0625
-- 
-- TS_NAME                   SG_NAME                               DROPPED_MB
-- ------------------------- ------------------------------ -----------------
-- WWW_YYYYYYYYYYY           BIN$S3VonPyYEwHgUxwAZQpddw==$0           10.0000
-- *************************                                -----------------
-- sum                                                                10.0000
-- 
-- 30 rows selected.

SET LINESIZE 1000
SET PAGESIZE 1000

BREAK ON ts_name SKIP 1
COMPUTE SUM AVG OF dropped_mb ON ts_name

COLUMN ts_name    FORMAT a25
COLUMN sg_name    FORMAT a30
COLUMN dropped_mb FORMAT 999,999,999.9999

SELECT tablespace_name AS ts_name
       , segment_name AS sg_name
       , SUM(bytes)/1024/1024 AS dropped_mb
FROM dba_segments
WHERE segment_name LIKE 'BIN$%'
GROUP BY tablespace_name, segment_name
ORDER BY 1, 2
/

-- TS_NAME                   SG_NAME                               DROPPED_MB
-- ------------------------- ------------------------------ -----------------
-- SYSAUX                    BIN$Mg+kVZJF6x/gUxwAZQoWpw==$0             .1875
--                           BIN$Mg+kVZJG6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJH6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJI6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJJ6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJK6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJL6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJM6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJN6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Ne0yO3q0q4bgUxwAZQo/Nw==$0             .1875
--                           BIN$Ne0yO3q1q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q2q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q3q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q4q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q5q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q6q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q7q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q8q4bgUxwAZQo/Nw==$0             .0625
-- *************************                                -----------------
-- avg                                                                  .0764
-- sum                                                                 1.3750
-- 
-- WWW_XXXXXXXXXXX           BIN$S3VonPzfEwHgUxwAZQpddw==$0            4.0000
--                           BIN$S3VonPzkEwHgUxwAZQpddw==$0            4.0000
--                           BIN$jbOtu8fCIXrgUxwAZQoTtg==$0        2,958.0000
--                           BIN$jbOtu8fDIXrgUxwAZQoTtg==$0          232.0000
--                           BIN$jbOtu8fEIXrgUxwAZQoTtg==$0          976.0000
--                           BIN$jbOtu8fFIXrgUxwAZQoTtg==$0        1,216.0000
--                           BIN$jbOtu8fGIXrgUxwAZQoTtg==$0          128.0000
--                           BIN$jbOtu8fHIXrgUxwAZQoTtg==$0          192.0000
--                           BIN$je2SMUSfr6TgUxwAZQqyLQ==$0           61.0000
--                           BIN$je2SMUSgr6TgUxwAZQqyLQ==$0          336.0000
--                           BIN$lWKwh7pwJSngUxwAZQoxFQ==$0             .0625
-- *************************                                -----------------
-- avg                                                               555.1875
-- sum                                                             6,107.0625
-- 
-- WWW_YYYYYYYYYYY           BIN$S3VonPyYEwHgUxwAZQpddw==$0           10.0000
-- *************************                                -----------------
-- avg                                                                10.0000
-- sum                                                                10.0000
-- 
-- 
-- 30 rows selected.

SET LINESIZE 1000
SET PAGESIZE 1000

BREAK ON ts_name SKIP 1
COMPUTE SUM LABEL "Summary" AVG LABEL "Average" OF dropped_mb ON ts_name

COLUMN ts_name    FORMAT a25
COLUMN sg_name    FORMAT a30
COLUMN dropped_mb FORMAT 999,999,999.9999

SELECT tablespace_name AS ts_name
       , segment_name AS sg_name
       , SUM(bytes)/1024/1024 AS dropped_mb
FROM dba_segments
WHERE segment_name LIKE 'BIN$%'
GROUP BY tablespace_name, segment_name
ORDER BY 1, 2
/

-- TS_NAME                   SG_NAME                               DROPPED_MB
-- ------------------------- ------------------------------ -----------------
-- SYSAUX                    BIN$Mg+kVZJF6x/gUxwAZQoWpw==$0             .1875
--                           BIN$Mg+kVZJG6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJH6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJI6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJJ6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJK6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJL6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJM6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Mg+kVZJN6x/gUxwAZQoWpw==$0             .0625
--                           BIN$Ne0yO3q0q4bgUxwAZQo/Nw==$0             .1875
--                           BIN$Ne0yO3q1q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q2q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q3q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q4q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q5q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q6q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q7q4bgUxwAZQo/Nw==$0             .0625
--                           BIN$Ne0yO3q8q4bgUxwAZQo/Nw==$0             .0625
-- *************************                                -----------------
-- Average                                                              .0764
-- Summary                                                             1.3750
-- 
-- WWW_XXXXXXXXXXX           BIN$S3VonPzfEwHgUxwAZQpddw==$0            4.0000
--                           BIN$S3VonPzkEwHgUxwAZQpddw==$0            4.0000
--                           BIN$jbOtu8fCIXrgUxwAZQoTtg==$0        2,958.0000
--                           BIN$jbOtu8fDIXrgUxwAZQoTtg==$0          232.0000
--                           BIN$jbOtu8fEIXrgUxwAZQoTtg==$0          976.0000
--                           BIN$jbOtu8fFIXrgUxwAZQoTtg==$0        1,216.0000
--                           BIN$jbOtu8fGIXrgUxwAZQoTtg==$0          128.0000
--                           BIN$jbOtu8fHIXrgUxwAZQoTtg==$0          192.0000
--                           BIN$je2SMUSfr6TgUxwAZQqyLQ==$0           61.0000
--                           BIN$je2SMUSgr6TgUxwAZQqyLQ==$0          336.0000
--                           BIN$lWKwh7pwJSngUxwAZQoxFQ==$0             .0625
-- *************************                                -----------------
-- Average                                                           555.1875
-- Summary                                                         6,107.0625
-- 
-- WWW_YYYYYYYYYYY           BIN$S3VonPyYEwHgUxwAZQpddw==$0           10.0000
-- *************************                                -----------------
-- Average                                                            10.0000
-- Summary                                                            10.0000
-- 
-- 
-- 30 rows selected.
