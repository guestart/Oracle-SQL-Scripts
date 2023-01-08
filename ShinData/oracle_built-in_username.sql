REM
REM     Script:        oracle_built-in_username.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Nov 01, 2022
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Checking the built-in username of oracle database.
REM

SSELECT DISTINCT name
FROM (SELECT cid, cname, schema#
      FROM registry$
      UNION ALL
      SELECT a.cid, cname, b.schema#
      FROM registry$ a, registry$schemas b
      WHERE a.cid = b.cid
     ) c, user$ d
WHERE c.schema# = d.user#;

or

SELECT username
FROM dba_users
WHERE created < (SELECT created FROM v$database);
