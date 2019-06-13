REM
REM     Script:        all_prod_user.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 11, 2019
REM
REM     Purpose:  
REM       This sql script lists all of production users by dba_users (excluding sys related users).
REM

SET LINESIZE 200
SET PAGESIZE 200
COLUMN username       FORMAT a23
COLUMN account_status FORMAT a14

SELECT username
       , account_status
FROM dba_users
WHERE username NOT IN
(
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
ORDER BY 1 DESC
/
