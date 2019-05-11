-- Adding the first following 6 lines code to sys user's trigger directory.

CREATE OR REPLACE TRIGGER on_logon_trigger
AFTER LOGON ON DATABASE  
BEGIN
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(SYS_CONTEXT('userenv', 'ip_address')); 
END;  
/

REM
REM     Script:        per_machine_act_conn_num_aggr_by_user.sql
REM     Author:        Quanwen Zhao
REM     Dated:         May 11, 2019
REM
REM     Purpose:  
REM       This sql script shows per machine's active connect numbers after aggregating by username on v$session,
REM       meanwhile/furthermore shows column client_info, that's to say, client's ip address.
REM

SET LINESIZE 200
SET PAGESIZE 200
COLUMN username    FORMAT a25
COLUMN machine     FORMAT a20
COLUMN client_info FORMAT a20
COLUMN program     FORMAT a28
COLUMN status      FORMAT a8

SELECT username
       , machine
       , client_info
       , program
       , status
       , count(*)
FROM v$session
WHERE username IS NOT NULL
AND   status = 'ACTIVE'
GROUP BY username
         , machine
         , client_info
         , program
         , status
ORDER BY count(*) DESC
         , status
/
