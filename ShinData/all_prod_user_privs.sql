REM
REM     Script:        all_prod_user_privs.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Mar 29, 2023
REM
REM     Last tested:
REM             11.2.0.4
REM             12.2.0.1
REM             19.3.0.0
REM
REM     Purpose:
REM       Listing all of the privileges of production/business users of oracle database.
REM

(1) system privileges:

-- 10g, 11g:

set linesize 200
set pagesize 200
col grantee for a15
col privilege for a25

SELECT grantee,
       privilege
FROM dba_sys_privs
WHERE grantee IN (SELECT username
                  FROM dba_users
                  WHERE created > (SELECT created FROM v$database)
                 )
ORDER BY 1, 2;

-- 12c and later:

set linesize 200
set pagesize 200
col grantee for a15
col privilege for a25

SELECT grantee,
       privilege
FROM dba_sys_privs
WHERE grantee IN (SELECT username
                  FROM dba_users
                  WHERE oracle_maintained = 'N'
                 )
ORDER BY 1, 2;
                 
(2) role privileges:                 
                 
-- 10g, 11g:

set linesize 200
set pagesize 200
col grantee for a15
col granted_role for a25

SELECT grantee,
       granted_role
FROM dba_role_privs
WHERE grantee IN (SELECT username
                  FROM dba_users
                  WHERE created > (SELECT created FROM v$database)
                 )
ORDER BY 1, 2;

-- 12c and later:

set linesize 200
set pagesize 200
col grantee for a15
col granted_role for a25

SELECT grantee,
       granted_role
FROM dba_role_privs
WHERE grantee IN (SELECT username
                  FROM dba_users
                  WHERE oracle_maintained = 'N'
                 )
ORDER BY 1, 2;

(3) object privileges:

-- 10g, 11g:

set linesize 200
set pagesize 200
col grantee for a15
col owner for a15
col table_name for a35
col privilege for a25

SELECT grantee,
       owner,
       table_name,
       privilege
FROM dba_tab_privs
WHERE grantee IN (SELECT username
                  FROM dba_users
                  WHERE created > (SELECT created FROM v$database)
                 )
ORDER BY 1, 2, 3, 4;

-- 12c and later:

set linesize 200
set pagesize 200
col grantee for a15
col owner for a15
col table_name for a35
col privilege for a25

SELECT grantee,
       owner,
       table_name,
       privilege
FROM dba_tab_privs
WHERE grantee IN (SELECT username
                  FROM dba_users
                  WHERE oracle_maintained = 'N'
                 )
ORDER BY 1, 2, 3, 4;
