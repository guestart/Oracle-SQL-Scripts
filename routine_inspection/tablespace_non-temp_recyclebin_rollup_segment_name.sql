REM
REM     Script:        tablespace_non-temp_recyclebin_rollup_segment_name.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 05, 2019
REM
REM     Purpose:  
REM       This SQL script usually uses to check the per blocks number (or dropped size) and its SUM by ROLLUP (segment_name)
REM       on non-temp tablespaces of Oracle Database.
REM

SET LINESIZE 1000
SET PAGESIZE 1000

COLUMN ts_name    FORMAT a25
COLUMN sg_name    FORMAT a30
COLUMN dropped_mb FORMAT 999,999,999.9999

SELECT tablespace_name        AS ts_name
       , segment_name         AS sg_name
       , SUM(blocks)          AS blocks_number
       , SUM(bytes)/1024/1024 AS dropped_mb
FROM dba_segments
WHERE segment_name LIKE 'BIN$%'
GROUP BY tablespace_name, rollup(segment_name)
ORDER BY 1, 2
;

-- TS_NAME                   SG_NAME                        BLOCKS_NUMBER        DROPPED_MB
-- ------------------------- ------------------------------ ------------- -----------------
-- SYSAUX                    BIN$Mg+kVZJF6x/gUxwAZQoWpw==$0            24             .1875
-- SYSAUX                    BIN$Mg+kVZJG6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Mg+kVZJH6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Mg+kVZJI6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Mg+kVZJJ6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Mg+kVZJK6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Mg+kVZJL6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Mg+kVZJM6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Mg+kVZJN6x/gUxwAZQoWpw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q0q4bgUxwAZQo/Nw==$0            24             .1875
-- SYSAUX                    BIN$Ne0yO3q1q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q2q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q3q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q4q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q5q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q6q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q7q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                    BIN$Ne0yO3q8q4bgUxwAZQo/Nw==$0             8             .0625
-- SYSAUX                                                             176            1.3750
-- WWW_XXXXXXXXXXX           BIN$S3VonPzfEwHgUxwAZQpddw==$0           512            4.0000
-- WWW_XXXXXXXXXXX           BIN$S3VonPzkEwHgUxwAZQpddw==$0           512            4.0000
-- WWW_XXXXXXXXXXX           BIN$jbOtu8fCIXrgUxwAZQoTtg==$0        378624        2,958.0000
-- WWW_XXXXXXXXXXX           BIN$jbOtu8fDIXrgUxwAZQoTtg==$0         29696          232.0000
-- WWW_XXXXXXXXXXX           BIN$jbOtu8fEIXrgUxwAZQoTtg==$0        124928          976.0000
-- WWW_XXXXXXXXXXX           BIN$jbOtu8fFIXrgUxwAZQoTtg==$0        155648        1,216.0000
-- WWW_XXXXXXXXXXX           BIN$jbOtu8fGIXrgUxwAZQoTtg==$0         16384          128.0000
-- WWW_XXXXXXXXXXX           BIN$jbOtu8fHIXrgUxwAZQoTtg==$0         24576          192.0000
-- WWW_XXXXXXXXXXX           BIN$je2SMUSfr6TgUxwAZQqyLQ==$0          7808           61.0000
-- WWW_XXXXXXXXXXX           BIN$je2SMUSgr6TgUxwAZQqyLQ==$0         43008          336.0000
-- WWW_XXXXXXXXXXX           BIN$lWKwh7pwJSngUxwAZQoxFQ==$0             8             .0625
-- WWW_XXXXXXXXXXX                                                 781704        6,107.0625
-- WWW_YYYYYYYYYYY           BIN$S3VonPyYEwHgUxwAZQpddw==$0          1280           10.0000
-- WWW_YYYYYYYYYYY                                                   1280           10.0000
-- 
-- 33 rows selected.
