REM
REM     Script:        connect_machine_via_sql_id.sql
REM     Author:        Quanwen Zhao
REM     Dated:         Feb 12, 2020                                                  
REM
REM     Purpose:  
REM       This sql script usually uses to check the machine name connecting to Oracle Database Server
REM       via inputting a specific value of SQL_ID.
REM

SET VERIFY OFF

SET LINESIZE 150
SET PAGESIZE 300

COLUMN username    FORMAT a18
COLUMN machine     FORMAT a15
COLUMN client_info FORMAT a15

SELECT b.username
     , b.machine
     , b.client_info
FROM v$sql a
   , v$session b
WHERE a.hash_value = b.sql_hash_value
AND a.sql_id = '&sql_id'
/
