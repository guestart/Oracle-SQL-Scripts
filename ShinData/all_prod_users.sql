REM
REM     Script:        all_prod_users.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 29, 2023
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Listing all of production/business users of oracle database.
REM

-- how to exclude oracle internal user?
-- https://stackoverflow.com/questions/37338237/list-of-all-the-user-excluding-default-users

-- https://zhuanlan.zhihu.com/p/449512111

-- 10g, 11g:

SELECT username
FROM dba_users
MINUS
SELECT username
FROM dba_users
WHERE created < (SELECT created FROM v$database)
ORDER BY username;

or

SELECT username
FROM dba_users
WHERE created > (SELECT created FROM v$database)
ORDER BY username;

-- 12c and later:

SELECT username
FROM dba_users
WHERE oracle_maintained = 'N'
ORDER BY username;
